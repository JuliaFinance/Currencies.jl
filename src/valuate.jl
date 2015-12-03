# Valuate Monetary or Basket using a table of exchange rates.

"""
A table of exchange rates denominated in some currency. In which currency it is
denominated is unimportant, so long as all exchange rates are denominated in the
same currency. The denomination currency need not even exist in the table.

Optionally, `ExchangeRateTable` objects may contain information about the date
for which they apply. If this isn't provided, then the current date is used.
"""
immutable ExchangeRateTable <: Associative{Symbol, Float64}
    table::Dict{Symbol, Float64}
    date::Date

    ExchangeRateTable(date, table) = new(table, date)
    ExchangeRateTable(table) = new(table, Date(now()))
end
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

"""
Reduces the given `Monetary` or `Basket` to a value in a single specified
currency, using the given exchange rate table. The exchange rate table can
either be an `ExchangeRateTable` or any other `Associative` mapping `Symbol`
to `Real`.

    rates = ExchangeRateTable(:USD => 1.0, :CAD => 0.75)
    valuate(rates, :CAD, 21USD)  # 28CAD
"""
function valuate{T,U}(table, as::Symbol, amount::Monetary{T,U})
    rate = table[T] / table[as]
    (int(amount) * rate / 10^decimals(T)) * one(Monetary{as,U})
end

function valuate(table, as::Symbol, amount::Basket)
    acc = 0.0
    for m in amount
        from = currency(m)
        rate = table[from] / table[as]
        acc += int(m) * rate / 10^decimals(from)
    end
    acc * one(Monetary{as})
end
