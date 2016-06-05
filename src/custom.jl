#= Custom currency creation =#

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
function newcurrency!(T::Symbol, name::AbstractString, expt::Int)
    DATA[T] = (expt, Compat.UTF8String(name), 0)
    Monetary(T)
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
        nothing
    end |> esc
end
