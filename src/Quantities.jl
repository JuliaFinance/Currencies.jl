#=
Experimental quantities. None of the content of this module is currently
exported.

The entire module is based off the idea that:

 - A physical quantity, unless dimensionless, is a Number times a Unit.
 - When dimensionless, the Unit itself is a Number and it's a multiplicative
   identity.
 - It is therefore acceptable for a Unit to not have its own type.
=#

module Quantities

export unit

# for dimensionless quantities, unit is one
unit{T<:Number}(::Type{T}) = one(T)
unit(x::Number) = one(x)

end  # module Quantities
