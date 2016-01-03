#= Local convention for currency symbol. =#

# default: :after
const LOCAL_SYMBOL_LOCATION = Dict{Symbol, Symbol}(
    :AUD => :before,
    :CAD => :before,
    :USD => :before,
    :GBP => :before)
