module Currencies

using MacroTools
import Base: +, -, *, /, ==

# Exports
export currency, Monetary, @usingcurrencies
export simplefv, compoundfv
export StaticBasket, DynamicBasket

# Abstract class for Monetary-like things
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

end # module
