using JSON3

# Data obtained from https://datahub.io/core/country-codes
inputname = joinpath(@__DIR__,"country-codes.json")
outputname = joinpath(@__DIR__, "currencies.jl")

const country_list = open(io -> JSON3.read(io), inputname)

const SymAlpha = Symbol("ISO4217-currency_alphabetic_code")
const SymUnit = Symbol("ISO4217-currency_minor_unit")
const SymName = Symbol("ISO4217-currency_name")
const SymCode = Symbol("ISO4217-currency_numeric_code")

function genfile(io)
    for country in country_list
        (symlist = country[SymAlpha]) === nothing && continue
        (unitlist = country[SymUnit]) === nothing && continue
        (namelist = country[SymName]) === nothing && continue
        (codelist = country[SymCode]) === nothing && continue
        symbols = split(symlist, ',')
        units = split(string(unitlist), ',')
        names = split(namelist, ',')
        codes = split(string(codelist), ',')

        for (symbol, unit, code, name) in zip(symbols, units, codes, names)
            length(symbol) != 3 && continue
            println(io,"""Currency(:$symbol,$unit,$code,"$name")""")
        end
    end
end

open(io -> genfile(io), outputname, "w")
