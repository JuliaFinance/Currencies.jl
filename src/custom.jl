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
    DATA[symb] = (expt, UTF8String(name))
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

"""
Get a brief human-readable English-language description of the currency. The
description should begin with the common name of the currency, which should
describe it unambiguously (up to variations on the same currency). Optionally,
parentheses following the main description may include additional information
(such as the unit of a major currency unit).

This function may be called with either a symbol, a `Monetary` type, or a
`Monetary` object.
"""
currencyinfo(s::Symbol) = DATA[s][2]
currencyinfo{T,U,V}(::Type{Monetary{T,U,V}}) = currencyinfo(T)
currencyinfo{T<:Monetary}(::Type{T}) = currencyinfo(filltype(T))
currencyinfo(m::Monetary) = currencyinfo(typeof(m))
