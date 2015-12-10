# Tools for creating and using custom currencies

"""
Add a new currency to the (global) currency list and return a unit for that
currency. Prefer the `@usingcustomcurrency` macro, which leads to more clear
code, whenever possible. This function takes three arguments: the symbol for the
currency, a string description of the currency (following the conventions
outlined in the documentation for `currencyinfo`), and an exponent representing
the number of decimal points to describe the minor currency unit in terms of the
major currency unit. Conventionally, the symbol used to describe custom
currencies should consist of only lowercase letters.

    btc = newcurrency!(:btc, "Bitcoin", 8)  # 1.00000000 BTC
"""
function newcurrency!(symb::Symbol, name::AbstractString, expt::Int)
    DATA[symb] = (expt, UTF8String(name), 0)
    one(Monetary{symb})
end

"""
Add a new currency to the (global) currency list and assign a variable in the
local namespace to that currency's unit. Provide three arguments: an identifier
for the currency, a string description of the currency (following the
conventions outlined in the documentation for `currencyinfo`), and an exponent
representing the number of decimal points to describe the minor currency unit in
terms of the major currency unit. Conventionally, the identifer used to describe
custom currencies should consist of only lowercase letters.

    @usingcustomcurrency btc "Bitcoin" 8
    10btc  # 10.00000000 btc
"""
macro usingcustomcurrency(symb, name, exponent)
    quote
        $symb = newcurrency!($(Expr(:quote, symb)), $name, $exponent)
    end |> esc
end

# Currency info lookup functions.

# Macro to define flexible lookup functions that accept type or Monetary object.
macro flexible(assignment)
    @assert assignment.head == :(=)
    symb = assignment.args[1].args[1]
    quote
        $assignment
        $symb{T,U,V}(::Type{Monetary{T,U,V}}) = $symb(T)
        $symb{T<:Monetary}(::Type{T}) = $symb(filltype(T))
        $symb(m::Monetary) = $symb(typeof(m))
    end |> esc
end

"""
    currency(m::Monetary) → Symbol

Return a symbol corresponding to the ISO 4217 currency code of the currency that
the given monetary amount is representing. For example, `currency(80USD)` will
return `:USD`. If the given monetary value is of a non-ISO 4217 currency, then
the returned symbol should contain only lowercase letters.

Prefer `iso4217alpha` to this function if a string is desired.
"""
currency{T}(m::Monetary{T}) = T

"""
    decimals(m::Monetary) → Int
    decimals(s::Symbol)   → Int
    decimals(d::DataType) → Int

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

"""
Get a brief human-readable English-language description of the currency. The
description should begin with the common name of the currency, which should
describe it unambiguously (up to variations on the same currency). Optionally,
parentheses following the main description may include additional information
(such as the unit of a major currency unit).

This function may be called with either a symbol, a `Monetary` type, or a
`Monetary` object.
"""
function currencyinfo end
@flexible currencyinfo(s::Symbol) = DATA[s][2]

"""
    iso4217num(s::Symbol)   → Int
    iso4217num(m::Monetary) → Int
    iso4217num(t::DataType) → Int

Get the ISO 4217 numeric code for a currency. For custom currencies, a value of
`0` will be returned. This function may be called with either a symbol, a
`Monetary` type, or a `Monetary` object. Note that most applications should
zero-pad this code to three digits.
"""
function iso4217num end
@flexible iso4217num(s::Symbol) = DATA[s][3]


"""
    iso4217alpha(s::Symbol)   → UTF8String
    iso4217alpha(m::Monetary) → UTF8String
    iso4217alpha(t::DataType) → UTF8String

Get the ISO 4217 alphabetic code for a currency. For custom currencies, a
lowercase string will be returned, and this should not be interpreted as an ISO
4217 code. Otherwise, a three-letter uppercase string will be returned. This
function may be called with either a symbol, a `Monetary` type, or a `Monetary`
object. For type stability, this function returns a UTF8String always, even when
the currency code contains no non-ASCII characters.
"""
function iso4217alpha end
@flexible iso4217alpha(s::Symbol) = s |> string |> UTF8String
