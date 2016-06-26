module CurrencyData

using Compat

include("currencies.jl")
include("locale.jl")
include("symbols.jl")

export ISO4217, SHORT_SYMBOL, LONG_SYMBOL, LOCAL_SYMBOL_LOCATION

end  # module CurrencyData
