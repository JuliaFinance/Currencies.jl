module Currencies

using MacroTools
import Base: +, -, *, /, ==

# Exports
export AbstractMonetary, Monetary
export currency, currencyinfo, @usingcurrencies
export valuate, ExchangeRateTable
export Basket, StaticBasket, DynamicBasket
export simplefv, compoundfv
export newcurrency!, @usingcustomcurrency

# Abstract class for Monetary-like things
"""
The abstract type of objects representing a single value in one currency, or a
collection of values in a set of currencies. These objects should behave like
`Monetary` or `Basket` objects.
"""
abstract AbstractMonetary

# Currency data
include("data.jl")

# Monetary type
include("monetary.jl")

# Baskets & basket math
include("basket.jl")

# Valuations
include("valuate.jl")

# Simple investment math
include("investments.jl")

# @usingcurrencies macro
include("usingcurrencies.jl")

# Custom currencies
include("custom.jl")

end # module
