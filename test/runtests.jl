using Currencies
using FixedPointDecimals

using Test
using Dates

# Get currencies for tests
@usingcurrencies USD, CAD, EUR, GBP, JPY, AUD, INR
@usingcurrencies CNY  # test one-currency version

# Data tests
include("data.jl")

# Basic functionality tests
include("monetary.jl")
include("basket.jl")
include("mixed.jl")

# Currencies
include("data-access.jl")

# Display tests
include("display.jl")

# Custom currencies
include("custom.jl")

# Computations tests
include("valuation.jl")

# README & Doc examples
include("examples.jl")
