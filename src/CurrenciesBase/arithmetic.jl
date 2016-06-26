#= Monetary arithmetic functions =#

# numeric operations
Base.zero{T,U,V}(::Type{Monetary{T,U,V}}) = Monetary{T,U,V}(0)
Base.zero{T<:Monetary}(::Type{T}) = zero(filltype(T))

# NB: one returns multiplicative identity, which does not have units
Base.one{T,U,V}(::Type{Monetary{T,U,V}}) = one(U)
Base.one{T<:Monetary}(::Type{T}) = one(filltype(T))

# mathematical number-like operations
Base.abs{T<:Monetary}(m::T) = T(abs(m.val))

# a note on this one: a sign does NOT include the unit
# quantity = sign * magnitude * unit
Base.sign(m::Monetary) = sign(m.val)

# on types
Base.zero{T<:AbstractMonetary}(::T) = zero(T)
Base.one{T<:AbstractMonetary}(::T) = one(T)

# comparisons
=={T<:Monetary}(m::T, n::T) = m.val == n.val
Base.isless{T<:Monetary}(m::T, n::T) = isless(m.val, n.val)

# unary plus/minus
+ m::AbstractMonetary = m
-{T<:Monetary}(m::T) = T(-m.val)

# arithmetic operations on two monetary values
+{T<:Monetary}(m::T, n::T) = T(m.val + n.val)
-{T<:Monetary}(m::T, n::T) = T(m.val - n.val)
/{T<:Monetary}(m::T, n::T) = m.val / n.val

# arithmetic operations on monetary and dimensionless values
*{T<:Monetary}(m::T, i::Integer) = T(m.val * i)
*{T<:Monetary}(i::Integer, m::T) = T(i * m.val)
*{T,U,V}(f::Real, m::Monetary{T,U,V}) = Monetary{T,U,V}(round(U, f * m.val))
*{T,U,V}(m::Monetary{T,U,V}, f::Real) = Monetary{T,U,V}(round(U, m.val * f))
m::Monetary / f::Real = m * inv(f)

# Note that quotient is an integer, but remainder is a monetary value.

const DIVS = if VERSION < v"0.5-"
    ((:div, :rem, :divrem),
     (:fld, :mod, :fldmod))
else
    ((:div, :rem, :divrem),
     (:fld, :mod, :fldmod),
     (:fld1, :mod1, :fldmod1))
end

for (dv, rm, dvrm) in DIVS
    @eval function Base.$(dvrm){T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V})
        quotient, remainder = $(dvrm)(m.val, n.val)
        quotient, Monetary{T,U,V}(remainder)
    end
    @eval Base.$(dv){T<:Monetary}(m::T, n::T) = $(dv)(m.val, n.val)
    @eval Base.$(rm){T,U,V}(m::Monetary{T,U,V}, n::Monetary{T,U,V}) =
        Monetary{T,U,V}($(rm)(m.val, n.val))
end
