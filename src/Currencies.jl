module Currencies

# Data obtained from https://datahub.io/core/country-codes
# Consider downloading data in build.jl?

using DelimitedFiles

export Currency

const (data,headers) = readdlm(joinpath(@__DIR__,"data","country-codes.csv"),',',header=true)

struct Currency{T} 
    function Currency{T}() where T
        c = new()
        list[T] = c
        return c
    end
end
const list = Dict{Symbol,Currency}()

const (nrow,ncol) = size(data)
for i in 1:nrow
    currencies = split(data[i,10],",")
    currency_units = split(string(data[i,12]),",")
    currency_names = split(data[i,13],",")
    currency_codes = split(string(data[i,14]),",")
    for (currency,currency_unit,currency_name,currency_code) in zip(currencies,currency_units,currency_names,currency_codes)
        if (length(currency) == 3) & !isdefined(Currencies,Symbol(currency))
            @eval Currencies begin
                $(Symbol(currency)) = Currency{Symbol($(currency))}()
                unit(::Currency{Symbol($(currency))}) = parse(Int,$(currency_unit))
                name(::Currency{Symbol($(currency))}) = $(currency_name)
                code(::Currency{Symbol($(currency))}) = parse(Int,$(currency_code))
                Base.show(io::Base.IO,::Currency{Symbol($(currency))}) = print(io,$(currency))
            end
        end
    end
end

end