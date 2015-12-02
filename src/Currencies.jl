module Currencies

using MacroTools
import Base: +, -, *, /, ==

# Exports
export AbstractMonetary, Monetary
export currency, @usingcurrencies
export simplefv, compoundfv, currencyinfo
export Basket, StaticBasket, DynamicBasket
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

# Simple investment math
include("investments.jl")

# Baskets & basket math
include("basket.jl")

# @usingcurrencies macro
include("usingcurrencies.jl")

# Custom currencies
include("custom.jl")

end # module
