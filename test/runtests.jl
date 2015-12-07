using Currencies
using Base.Test

# Get currencies for tests
@usingcurrencies USD, CAD, EUR, GBP, JPY
@usingcurrencies CNY

# Basic functionality tests
include("monetary.jl")
include("basket.jl")

# Custom & Default currencies
include("currencies.jl")

# Computations tests
include("valuation.jl")
include("investment.jl")

# Display tests
include("display.jl")

# README & Doc examples
include("examples.jl")
