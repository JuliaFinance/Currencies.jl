#= Monetary Arithmetic functions =#

# numeric operations
Base.zero{T,U,V}(::Type{Monetary{T,U,V}}) = Monetary{T,U,V}(0)
Base.one{T,U,V}(::Type{Monetary{T,U,V}}) = Monetary{T,U,V}(10^V)
Base.zero{T<:Monetary}(::Type{T}) = zero(filltype(T))
Base.one{T<:Monetary}(::Type{T}) = one(filltype(T))
Base.float(m::Monetary) = m.val / 10.0^decimals(m)

# mathematical number-like operations
Base.abs{T,U,V}(m::Monetary{T,U,V}) = Monetary{T,U,V}(abs(m.val))

# a note on this one:
# a sign does NOT include the unit
# quantity = sign * magnitude * one (unit)
# so we return something of type V
Base.sign(m::Monetary) = sign(m.val)

# on types
Base.zero{T<:AbstractMonetary}(::T) = zero(T)
Base.one{T<:AbstractMonetary}(::T) = one(T)

# comparisons
Base. ==(::Monetary, ::Monetary) = false
Base. =={T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) = m.val == n.val
Base.isless{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) =
    isless(m.val, n.val)

# unary plus/minus
Base. +(m::AbstractMonetary) = m
Base. -{T,U,V}(m::Monetary{T,U,V}) = Monetary{T,U,V}(-m.val)

# descriptive error messages for mixed arithmetic
Base. +(x::Monetary, y::Monetary) = throw(ArgumentError(
    "cannot add values of different types $(typeof(x)) and $(typeof(y))"))
Base. -(x::Monetary, y::Monetary) = throw(ArgumentError(
    "cannot subtract values of different types $(typeof(x)) and $(typeof(y))"))

# arithmetic operations
Base. +{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) =
    Monetary{T,U,V}(m.val + n.val)
Base. -{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) =
    Monetary{T,U,V}(m.val - n.val)
Base. *{T,U,V}(m::Monetary{T,U,V}, i::Integer) = Monetary{T,U,V}(m.val * i)
Base. *{T,U,V}(i::Integer, m::Monetary{T,U,V}) = Monetary{T,U,V}(i * m.val)
Base. *{T,U,V}(f::Real, m::Monetary{T,U,V}) = Monetary{T,U,V}(round(f * m.val))
Base. *{T,U,V}(m::Monetary{T,U,V}, f::Real) = Monetary{T,U,V}(round(m.val * f))
Base. /{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) = m.val / n.val
Base. /(m::Monetary, f::Real) = m * (1/f)

# Note that quotient is an integer, but remainder is a monetary value.
function Base.divrem{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V})
    quotient, remainder = divrem(m.val, n.val)
    quotient, Monetary{T,U,V}(remainder)
end
Base.div{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) = div(m.val, n.val)
Base.rem{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) =
    Monetary{T,U,V}(rem(m.val, n.val))
