# Currencies.jl

[![Build Status](https://travis-ci.org/JuliaFinance/Currencies.jl.svg?branch=master)](https://travis-ci.org/JuliaFinance/Currencies.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/chnj7xc6r0deux92/branch/master?svg=true)](https://ci.appveyor.com/project/EricForgy/currencies-jl/branch/master)

## Purpose

This package provides standard currency names and codes.

## Data Source

Data for this package was obtained from https://datahub.io/core/country-codes.

## Usage

```julia
julia> using Currencies; import Currencies: unit, name, code, USD, PHP, HKD, SGD
julia> for ccy in [USD,PHP,HKD,SGD]
       println("Currency: $(ccy)")
       println("Name: $(name(ccy))")
       println("Code: $(code(ccy))")
       println("Minor Unit: $(unit(ccy))\n")
       end
       
Currency: USD
Name: US Dollar
Code: 840
Minor Unit: 2

Currency: PHP
Name: Philippine Piso
Code: 608
Minor Unit: 2

Currency: HKD
Name: Hong Kong Dollar
Code: 344
Minor Unit: 2

Currency: SGD
Name: Singapore Dollar
Code: 702
Minor Unit: 2
```
