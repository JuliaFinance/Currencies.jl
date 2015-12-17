using Currencies

if VERSION ≥ v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

# Get currencies for tests
@usingcurrencies USD, CAD, EUR, GBP, JPY, AUD
@usingcurrencies CNY

# Basic functionality tests
include("monetary.jl")
include("basket.jl")

# Custom & Default currencies
include("currencies.jl")

# Display tests
include("display.jl")

# Computations tests
include("valuation.jl")
include("investment.jl")

# README & Doc examples
include("examples.jl")
