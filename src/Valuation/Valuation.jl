module Valuation

using Requests

using ..CurrenciesBase
import ..CurrenciesBase: filltype

export valuate, ExchangeRateTable, ecbrates

# Valuate Monetary or Basket using a table of exchange rates.

"""
A table of exchange rates denominated in some currency. In which currency it is
denominated is unimportant, so long as all exchange rates are denominated in the
same currency. The denomination currency need not even exist in the table.

Optionally, `ExchangeRateTable` objects may contain information about the date
for which they apply. If this isn't provided, then the current date is used.
"""
immutable ExchangeRateTable <: Associative{Symbol, Float64}
    date::Date
    table::Dict{Symbol, Float64}
end
ExchangeRateTable(table) = ExchangeRateTable(Date(now()), table)
ExchangeRateTable(entries::Pair{Symbol, Float64}...) =
    ExchangeRateTable(Dict(entries...))
ExchangeRateTable(date::Date, entries::Pair{Symbol, Float64}...) =
    ExchangeRateTable(date, Dict(entries...))

Base.start(ert::ExchangeRateTable) = start(ert.table)
Base.next(ert::ExchangeRateTable, s) = next(ert.table, s)
Base.done(ert::ExchangeRateTable, s) = done(ert.table, s)
Base.length(ert::ExchangeRateTable) = length(ert.table)
Base.haskey(ert::ExchangeRateTable, k) = haskey(ert.table, k)
Base.getindex(ert::ExchangeRateTable, k) = ert.table[k]

const ECBCache = Dict{Date, ExchangeRateTable}()

function ecbrates_fresh(datestr::AbstractString)
    # get fixer.io data
    resp = Requests.json(get("https://api.fixer.io/$datestr", timeout=15))
    date = Date(resp["date"])
    table = Dict{Symbol, Float64}()
    for (k, v) in resp["rates"]
        table[Symbol(k)] = 1.0/v
    end
    table[Symbol(resp["base"])] = 1.0

    # cache and return
    ert = ExchangeRateTable(date, table)
    ECBCache[date] = ert
    return ert
end
ecbrates_fresh(date::Date) = ecbrates_fresh(string(date))
ecbrates_fresh() = ecbrates_fresh("latest")

"""
    ecbrates()           → ExchangeRateTable
    ecbrates(date::Date) → ExchangeRateTable

Get an `ExchangeRateTable` from European Central Bank data for the specified
date, or for the most recent date available. European Central Bank data is not
available for all currencies, and it is often out of date. This function
requires a connection to the Internet, and reraises whatever exception is thrown
from the `Requests` package if the connection fails for any reason.

Data is retrieved from https://fixer.io/, and then cached in memory to avoid
excessive network traffic. Because of the nature of cached data, an application
running for a long period of time may receive data that is one week or more out
of date.
"""
function ecbrates()
    date = Date(now(Dates.UTC))
    # try last seven days
    for _ in 1:7
        if haskey(ECBCache, date)
            return ECBCache[date]
        end
        date -= Dates.Day(1)
    end

    ecbrates_fresh()
end
ecbrates(date) = haskey(ECBCache, date) ? ECBCache[date] : ecbrates_fresh(date)

"""
    valuate(table, as::Symbol, amount::Monetary)   → Monetary{as}
    valuate(table, as::DataType, amount::Monetary) → as

Reduce the given `Monetary` or `Basket` to a value in a single specified
currency or of a single specified type, using the given exchange rate table. The
exchange rate table can either be an `ExchangeRateTable` or any other
`Associative` mapping `Symbol` to `Real`.

    rates = ExchangeRateTable(:USD => 1.0, :CAD => 0.75)
    valuate(rates, :CAD, 21USD)  # 28CAD
"""
function valuate{T,U,V,W}(table, as::Type{Monetary{U,V,W}}, amount::Monetary{T})
    rate = table[T] / table[U]
    amount / majorunit(amount) * rate * majorunit(as)
end

function valuate{U,V,W}(table, as::Type{Monetary{U,V,W}}, amount::Basket)
    acc = 0.0
    for m in amount
        from = currency(m)
        acc += m / majorunit(m) * table[from]
    end
    acc / table[U] * majorunit(as)
end

function valuate{U<:Monetary}(table, ::Type{U}, amount::AbstractMonetary)
    valuate(table, filltype(U), amount)
end

function valuate(table, T::Symbol, amount::AbstractMonetary)
    valuate(table, Monetary{T}, amount)
end

end
