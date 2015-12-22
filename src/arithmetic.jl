#= Monetary Arithmetic functions =#

# numeric operations
Base.zero{T,U,V}(::Type{Monetary{T,U,V}}) = Monetary{T,U,V}(0)
Base.one{T,U,V}(::Type{Monetary{T,U,V}}) = Monetary{T,U,V}(10^V)
Base.zero{T<:Monetary}(::Type{T}) = zero(filltype(T))
Base.one{T<:Monetary}(::Type{T}) = one(filltype(T))
Base.int(m::Monetary) = m.amt

# mathematical number-like operations
Base.abs{T,U,V}(m::Monetary{T,U,V}) = Monetary{T,U,V}(abs(m.amt))

# a note on this one:
# a sign does NOT include the unit
# quantity = sign * magnitude * one (unit)
# so we return something of type V
Base.sign(m::Monetary) = sign(m.amt)

# on types
Base.zero{T<:AbstractMonetary}(::T) = zero(T)
Base.one{T<:AbstractMonetary}(::T) = one(T)

# comparisons
Base. ==(::Monetary, ::Monetary) = false
Base. =={T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) = m.amt == n.amt
Base.isless{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) =
    isless(m.amt, n.amt)

# unary plus/minus
Base. +(m::AbstractMonetary) = m
Base. -{T,U,V}(m::Monetary{T,U,V}) = Monetary{T,U,V}(-m.amt)

# descriptive error messages for mixed arithmetic
Base. +(x::Monetary, y::Monetary) = throw(ArgumentError(
    "cannot add values of different types $(typeof(x)) and $(typeof(y))"))
Base. -(x::Monetary, y::Monetary) = throw(ArgumentError(
    "cannot subtract values of different types $(typeof(x)) and $(typeof(y))"))

# arithmetic operations
Base. +{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) =
    Monetary{T,U,V}(m.amt + n.amt)
Base. -{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) =
    Monetary{T,U,V}(m.amt - n.amt)
Base. *{T,U,V}(m::Monetary{T,U,V}, i::Integer) = Monetary{T,U,V}(m.amt * i)
Base. *{T,U,V}(i::Integer, m::Monetary{T,U,V}) = Monetary{T,U,V}(i * m.amt)
Base. *{T,U,V}(f::Real, m::Monetary{T,U,V}) = Monetary{T,U,V}(round(f * m.amt))
Base. *{T,U,V}(m::Monetary{T,U,V}, f::Real) = Monetary{T,U,V}(round(m.amt * f))
Base. /{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) = m.amt / n.amt
Base. /(m::Monetary, f::Real) = m * (1/f)

# Note that quotient is an integer, but remainder is a monetary value.
function Base.divrem{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V})
    quotient, remainder = divrem(m.amt, n.amt)
    quotient, Monetary{T,U,V}(remainder)
end
Base.div{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) = div(m.amt, n.amt)
Base.rem{T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) =
    Monetary{T,U,V}(rem(m.amt, n.amt))
