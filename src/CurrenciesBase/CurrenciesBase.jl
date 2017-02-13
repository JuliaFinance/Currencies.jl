module CurrenciesBase

import ..Currencies
using ..CurrencyData

import Base: +, -, *, /, ==
using Compat

# Exports
export AbstractMonetary, Monetary
export currency, decimals, majorunit, @usingcurrencies
export currencyinfo, iso4217num, iso4217alpha, shortsymbol, longsymbol
export newcurrency!, @usingcustomcurrency

# Monetary type, currencies, and arithmetic
include("monetary.jl")
include("currency.jl")
include("arithmetic.jl")
include("mixed.jl")

# Custom currencies and macros
include("usingcurrencies.jl")
include("custom.jl")

end  # module CurrenciesBase
