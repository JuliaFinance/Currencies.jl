module Currencies

using DataStructures
using MacroTools
using Requests

# Exports
export AbstractMonetary, Monetary
export currency, decimals, @usingcurrencies
export currencyinfo, iso4217num, iso4217alpha, shortsymbol, longsymbol
export valuate, ExchangeRateTable, ecbrates
export Basket, StaticBasket, DynamicBasket
export simplefv, compoundfv
export newcurrency!, @usingcustomcurrency
export format

# Currency data
include("data/currencies.jl")
include("data/symbols.jl")

# Monetary type, currencies, and arithmetic
include("monetary.jl")
include("currency.jl")
include("arithmetic.jl")

# Baskets
include("basket.jl")

# Computations (valuation & investments)
include("valuate.jl")
include("investments.jl")

# Interface (display, convenience macro)
include("format/formatting.jl")
include("usingcurrencies.jl")

end # module
