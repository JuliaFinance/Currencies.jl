#= Monetary arithmetic functions =#

# numeric operations
Base.zero(::Type{Monetary{T,U,V}}) where {T,U,V} = Monetary{T,U,V}(0)
Base.zero(::Type{T}) where {T<:Monetary} = zero(filltype(T))

# NB: one returns multiplicative identity, which does not have units
Base.one(::Type{Monetary{T,U,V}}) where {T,U,V} = one(U)

# mathematical number-like operations
Base.abs(m::T) where {T<:Monetary} = T(abs(m.val))

# a note on this one: a sign does NOT include the unit
# quantity = sign * magnitude * unit
Base.sign(m::Monetary) = sign(m.val)

# on types
Base.zero(::T) where {T<:AbstractMonetary} = zero(T)
Base.one(::T) where {T<:AbstractMonetary} = one(T)

# comparisons
==(m::T, n::T) where {T<:Monetary} = m.val == n.val
==(m::Monetary{T}, n::Monetary{T}) where {T} = (m - n).val == 0
m::Monetary == n::Monetary = m.val == n.val == 0
Base.isless(m::Monetary{T,U,V}, n::Monetary{T,U,V}) where {T,U,V} = isless(m.val, n.val)

# unary plus/minus
+ m::AbstractMonetary = m
-(m::T) where {T<:Monetary} = T(-m.val)

# arithmetic operations on two monetary values
+(m::Monetary{T,U,V}, n::Monetary{T,U,V}) where {T,U,V} = Monetary{T,U,V}(m.val + n.val)
-(m::Monetary{T,U,V}, n::Monetary{T,U,V}) where {T,U,V} = Monetary{T,U,V}(m.val - n.val)
/(m::Monetary{T,U,V}, n::Monetary{T,U,V}) where {T,U,V} = float(m.val) / float(n.val)

# arithmetic operations on monetary and dimensionless values
*(m::T, i::Real) where {T<:Monetary} = T(m.val * i)
*(i::Real, m::T) where {T<:Monetary} = T(i * m.val)
m::Monetary / f::Real = m * inv(f)

# Note that quotient is an integer, but remainder is a monetary value.

const DIVS = ((:div, :rem, :divrem),
              (:fld, :mod, :fldmod),
              (:fld1, :mod1, :fldmod1))

for (dv, rm, dvrm) in DIVS
    @eval function Base.$(dvrm)(m::Monetary{T,U,V}, n::Monetary{T,U,V}) where {T,U,V}
        quotient, remainder = $(dvrm)(m.val, n.val)
        quotient, Monetary{T,U,V}(remainder)
    end
    @eval Base.$(dv)(m::Monetary{T,U,V}, n::Monetary{T,U,V}) where {T,U,V} =
        $(dv)(m.val, n.val)
    @eval Base.$(rm)(m::Monetary{T,U,V}, n::Monetary{T,U,V}) where {T,U,V} =
        Monetary{T,U,V}($(rm)(m.val, n.val))
end
