module Baskets

using ..CurrenciesBase
import Base: +, -, *, /, ==

export Basket

include("impl.jl")
include("type.jl")
include("mixed.jl")

end
