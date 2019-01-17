__precompile__()

module Currencies

using CurrenciesBase

# Exports
export AbstractMonetary, Monetary
export currency, decimals, majorunit, @usingcurrencies
export currencyinfo, iso4217num, iso4217alpha, shortsymbol, longsymbol
export valuate, ExchangeRateTable, ecbrates
export Basket, StaticBasket, DynamicBasket
export simplefv, compoundfv
export newcurrency!, @usingcustomcurrency
export format

# DeclarativeFormatting (not specific to Currencies; under development)
include("DeclarativeFormatting/DeclarativeFormatting.jl")

include("Baskets/Basket.jl")
using .Baskets

include("Valuation/Valuation.jl")
using .Valuation

# Interface (display/formatting, convenience macro)
include("CurrencyFormatting/CurrencyFormatting.jl")
using .CurrencyFormatting

# Deprecations
include("deprecated.jl")

end # module
