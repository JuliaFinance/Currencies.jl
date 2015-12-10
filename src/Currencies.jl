module Currencies

using MacroTools
using Requests

# Exports
export AbstractMonetary, Monetary
export currency, decimals, @usingcurrencies
export currencyinfo, iso4217num, iso4217alpha
export valuate, ExchangeRateTable, ecbrates
export Basket, StaticBasket, DynamicBasket
export simplefv, compoundfv
export newcurrency!, @usingcustomcurrency

# Currency data
include("data.jl")

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
include("display.jl")
include("usingcurrencies.jl")

end # module
