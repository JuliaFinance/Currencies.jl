"""
Currencies

This package provides the `Currency` singleton type, based on the ISO 4167 standard
together with four methods:

- `symbol`: The symbol of the currency.
- `name`: The full name of the currency.
- `code`: The ISO 4167 code for the currency.
- `unit`: The minor unit, i.e. number of decimal places, for the currency.

See README.md for the full documentation

Copyright 2019-2020, Eric Forgy, Scott P. Jones and other contributors

Licensed under MIT License, see LICENSE.md
"""
module Currencies

export Currency

"""
This is a singleton type, intended to be used as a label for dispatch purposes
"""
struct Currency{S} end
function Currency(symbol::Symbol,unit::Int,code::Int,name::String)
    ccy = Currency{symbol}()
    list[symbol] = (unit,code,name)
    return ccy
end
const list = Dict{Symbol,Tuple{Int,Int,String}}()

include(joinpath(@__DIR__, "..", "deps", "currencies.jl"))

"""
Returns the symbol associated with this value
"""
function symbol end

"""
Returns the minor unit associated with this value
"""
function unit end

"""
Returns the ISO 4167 code associated with this value
"""
function code end

"""
Returns the ISO 4167 name associated with this value
"""
function name end

symbol(::Currency{S}) where {S} = S
unit(S::Symbol) = list[S][1]
code(S::Symbol) = list[S][2]
name(S::Symbol) = list[S][3]
unit(::Currency{S}) where {S} = unit(S)
code(::Currency{S}) where {S} = code(S)
name(::Currency{S}) where {S} = name(S)

end