module CurrenciesBase

using Compat

using ..CurrencyData

import Base: +, -, *, /, ==

# Exports
export AbstractMonetary, Monetary
export currency, decimals, @usingcurrencies
export currencyinfo, iso4217num, iso4217alpha, shortsymbol, longsymbol
export Basket
export newcurrency!, @usingcustomcurrency

# Monetary type, currencies, and arithmetic
include("monetary.jl")
include("currency.jl")
include("arithmetic.jl")

# Baskets
include("basket.jl")
include("mixed.jl")

# Custom currencies and macros
include("usingcurrencies.jl")
include("custom.jl")

end  # module CurrenciesBase
