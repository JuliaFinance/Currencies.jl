# Monetary type, and low-level operations

"""
A representation of a monetary value, denominated in some currency. The
currency used is part of the type and not the object. The value is internally
represented as a quantity of some integer type. The usual way to construct a
`Monetary` directly, if needed, is:

    Monetary(:USD, 100)  # 1.00 USD

Be careful about the decimal point, as the `Monetary` constructor takes an
integer, representing the number of smallest denominations of the currency.
Typically, this constructor is not called directly. It is easier to use the
`@usingcurrencies` macro and the `100USD` form instead.

Although this type is flexible enough to support values internally represented
as any integer type, such as `BigInt`, it is recommended to use the built-in
`Int` type on your architecture unless you need a bigger type. Do not mix
different kinds of internal types. To use a different internal representation,
give the internal type as a second type parameter to `Monetary`:

    Monetary{:USD, BigInt}(100)
"""
immutable Monetary{T, U} <: AbstractMonetary
    amt::U
end
Monetary(T::Symbol, x) = Monetary{T, typeof(x)}(x)

"""
Return a symbol (of uppercase letters) corresponding to the ISO 4217 currency
code of the currency that the given monetary amount is representing. For
example, `currency(80USD)` will return `:USD`.
"""
currency{T}(m::Monetary{T}) = T
decimals(c::Symbol) = DATA[c][1]

# numeric operations
Base.zero{T}(::Type{Monetary{T}}) = Monetary(T, 0)
Base.zero{T,U}(::Type{Monetary{T,U}}) = Monetary{T,U}(0)
Base.one{T}(::Type{Monetary{T}}) = Monetary(T, 10^decimals(T))
Base.one{T,U}(::Type{Monetary{T,U}}) = Monetary{T,U}(10^decimals(T))
Base.int(m::Monetary) = m.amt

# on types
Base.zero{T<:AbstractMonetary}(::T) = zero(T)
Base.one{T<:AbstractMonetary}(::T) = one(T)

# comparisons
Base. =={T,U}(m::Monetary{T,U}, n::Monetary{T,U}) = m.amt == n.amt
Base. =={T,U,V,W}(m::Monetary{T,U}, n::Monetary{V,W}) = false
Base.isless{T,U}(m::Monetary{T,U}, n::Monetary{T,U}) = isless(m.amt, n.amt)

# unary plus/minus
Base. +(m::AbstractMonetary) = m
Base. -{T,U}(m::Monetary{T,U}) = Monetary{T,U}(-m.amt)

# descriptive error messages for mixed arithmetic
Base. +{T,U}(::Monetary{T}, ::Monetary{U}) = throw(ArgumentError(
    "cannot add Monetary values of different currencies $T and $U"))
Base. -{T,U}(::Monetary{T}, ::Monetary{U}) = throw(ArgumentError(
    "cannot subtract Monetary values of different currencies $T and $U"))

# arithmetic operations
Base. +{T,U}(m::Monetary{T,U}, n::Monetary{T,U}) = Monetary{T,U}(m.amt + n.amt)
Base. -{T,U}(m::Monetary{T,U}, n::Monetary{T,U}) = Monetary{T,U}(m.amt - n.amt)
Base. *{T,U}(m::Monetary{T,U}, i::Integer) = Monetary{T,U}(m.amt * i)
Base. *{T,U}(i::Integer, m::Monetary{T,U}) = Monetary{T,U}(i * m.amt)
Base. *{T,U}(f::Real, m::Monetary{T,U}) = Monetary{T,U}(round(f * m.amt))
Base. *{T,U}(m::Monetary{T,U}, f::Real) = Monetary{T,U}(round(m.amt * f))
Base. /{T,U}(m::Monetary{T,U}, n::Monetary{T,U}) = m.amt / n.amt
Base. /(m::Monetary, f::Real) = m * (1/f)

# Note that quotient is an integer, but remainder is a monetary value.
function Base.divrem{T,U}(m::Monetary{T,U}, n::Monetary{T,U})
    quotient, remainder = divrem(m.amt, n.amt)
    quotient, Monetary{T,U}(remainder)
end
Base.div{T,U}(m::Monetary{T,U}, n::Monetary{T,U}) = div(m.amt, n.amt)
Base.rem{T,U}(m::Monetary{T,U}, n::Monetary{T,U}) =
    Monetary{T,U}(rem(m.amt, n.amt))

function curdisplay(num, dec)
    if dec == 0
        return num < 0 ? "−$(abs(num))" : num
    end
    unit = 10 ^ dec
    s, num = sign(num), abs(num)
    full = fld(num, unit)
    part = join(reverse(digits(num % unit, 10, dec)))
    if s < 0
        "−$full.$part"
    else
        "$full.$part"
    end
end

function Base.show(io::IO, m::Monetary)
    cur = currency(m)
    print(io, int(m) / 10.0^decimals(cur))
    print(io, cur)
end

function Base.writemime(io::IO, ::MIME"text/plain", m::Monetary)
    cur = currency(m)
    print(io, "$(curdisplay(m.amt, decimals(cur))) $cur")
end
