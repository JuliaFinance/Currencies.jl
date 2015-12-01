module Currencies

using MacroTools
import Base: +, -, *, /, ==

# Exports
export currency, Monetary, @usingcurrencies
export simplefv, compoundfv, currencyinfo
export StaticBasket, DynamicBasket
export newcurrency!, @usingcustomcurrency

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

# Custom currencies
include("custom.jl")

end # module
