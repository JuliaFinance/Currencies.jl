__precompile__()

module Currencies

# Exports
export AbstractMonetary, Monetary
export currency, decimals, @usingcurrencies
export currencyinfo, iso4217num, iso4217alpha, shortsymbol, longsymbol
export valuate, ExchangeRateTable, ecbrates
export Basket, StaticBasket, DynamicBasket
export simplefv, compoundfv
export newcurrency!, @usingcustomcurrency
export format

# Extra compatibility code
include("CurrenciesCompat/CurrenciesCompat.jl")

# DeclarativeFormatting (not specific to Currencies; under development)
include("DeclarativeFormatting/DeclarativeFormatting.jl")

# Currency data
include("CurrencyData/CurrencyData.jl")

# Core features
include("CurrenciesBase/CurrenciesBase.jl")
using .CurrenciesBase

include("Valuation/Valuation.jl")
using .Valuation

# Interface (display/formatting, convenience macro)
include("CurrencyFormatting/CurrencyFormatting.jl")
using .CurrencyFormatting

end # module
