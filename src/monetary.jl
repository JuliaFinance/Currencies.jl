# Monetary type, and low-level operations

"""
A representation of a monetary value, denominated in some currency. The
currency used is part of the type and not the object. The value is internally
represented as a quantity of some integer type. The usual way to construct a
`Monetary` directly, if needed, is:

    Monetary(:USD)      # 1.00 USD
    Monetary(:USD, 325) # 3.25 USD

Be careful about the decimal point, as the `Monetary` constructor takes an
integer, representing the number of smallest denominations of the currency.
Typically, this constructor is not called directly. It is easier to use the
`@usingcurrencies` macro and the `100USD` form instead.

Although this type is flexible enough to support values internally represented
as any integer type, such as `BigInt`, it is recommended to use the built-in
`Int` type on your architecture unless you need a bigger type. Do not mix
different kinds of internal types. To use a different internal representation,
change the type of the second argument to `Monetary`:

    Monetary(:USD, BigInt(100))

In some applications, the minor denomination of a currency is not precise
enough. It is sometimes useful to override the number of decimal points stored.
For these applications, a third type parameter can be provided, indicating the
number of decimal points to keep after the major denomination:

    Monetary{:USD, BigInt, 4}(10000)            # 1.0000 USD
    Monetary(:USD, BigInt(10000); precision=4)  # 1.0000 USD
"""
immutable Monetary{T, U, V} <: AbstractMonetary
    amt::U
end

function Monetary(T::Symbol, x; precision=decimals(T))
    if precision == -1
        throw(ArgumentError("Must provide precision for currency $T."))
    else
        Monetary{T, typeof(x), precision}(x)
    end
end

function Monetary(T::Symbol; precision=decimals(T), storage=Int)
    if precision == -1
        throw(ArgumentError("Must provide precision for currency $T."))
    else
        one(Monetary{T, storage, precision})
    end
end

"""
    filltype(typ) → typ

Fill in default type parameters to get a fully-specified concrete type from a
partially-specified one.
"""
filltype{T}(::Type{Monetary{T}}) = Monetary{T, Int, decimals(T)}
filltype{T,U}(::Type{Monetary{T,U}}) = Monetary{T, U, decimals(T)}

"""
Return a symbol corresponding to the ISO 4217 currency code of the currency that
the given monetary amount is representing. For example, `currency(80USD)` will
return `:USD`. If the given monetary value is of a non-ISO 4217 currency, then
the returned symbol should contain only lowercase letters.

Prefer `iso4217alpha` to this function if a string is desired.
"""
currency{T}(m::Monetary{T}) = T

"""
    decimals(money) → Int

Get the precision, in terms of the number of decimal places after the major
currency unit, of the given `Monetary` value or type. Alternatively, if given a
symbol, gets the default exponent (the number of decimal places to represent the
minor currency unit) for that symbol. Return `-1` if there is no sane minor
unit, such as for several kinds of precious metal.
"""
decimals(c::Symbol) = DATA[c][1]
decimals{T,U,V}(::Monetary{T,U,V}) = V
decimals{T,U,V}(::Type{Monetary{T,U,V}}) = V
decimals{T<:Monetary}(::Type{T}) = decimals(filltype(T))

# numeric operations
Base.zero{T,U,V}(::Type{Monetary{T,U,V}}) = Monetary{T,U,V}(0)
Base.one{T,U,V}(::Type{Monetary{T,U,V}}) = Monetary{T,U,V}(10^V)
Base.zero{T<:Monetary}(::Type{T}) = zero(filltype(T))
Base.one{T<:Monetary}(::Type{T}) = one(filltype(T))
Base.int(m::Monetary) = m.amt

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

function curdisplay(num, dec; useunicode=true)
    minus = useunicode ? '−' : '-'
    if dec == 0
        return num < 0 ? "$minus$(abs(num))" : num
    end
    unit = 10 ^ dec
    s, num = sign(num), abs(num)
    full = fld(num, unit)
    part = join(reverse(digits(num % unit, 10, dec)))
    if s < 0
        "$minus$full.$part"
    else
        "$full.$part"
    end
end

function Base.show(io::IO, m::Monetary)
    print(io, int(m) / 10.0^decimals(m))
    print(io, currency(m))
end

function Base.writemime(io::IO, ::MIME"text/plain", m::Monetary)
    cur = currency(m)
    print(io, "$(curdisplay(m.amt, decimals(m))) $cur")
end

function Base.writemime(io::IO, ::MIME"text/latex", m::Monetary)
    cur = currency(m)
    num = curdisplay(m.amt, decimals(m); useunicode=false)
    print(io, "\$$num\\,\\mathrm{$cur}\$")
end
