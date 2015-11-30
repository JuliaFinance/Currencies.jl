# Currencies

[![Build Status](https://travis-ci.org/TotalVerb/Currencies.jl.svg?branch=master)](https://travis-ci.org/TotalVerb/Currencies.jl)

## Purpose
This package is not intended to replace the excellent [FinancialMarkets.jl](https://github.com/imanuelcostigan/FinancialMarkets.jl) package. Instead, this package provides a much simpler interface to using a wide variety of currencies with checked arithmetic in Julia. The motivation for this package comes from the nasty trap of the relative convenience of using floating point arithmetic for currency computations, combined with the perils of using floating point comparisons. Instead, fixed point decimals should be preferred.

This package provides a clean interface for creating currency objects and manipulating them. It is user-friendly and provides some basic but useful features for calculating investments on the command line.

## Data Source
The currency-related information for this package comes from [this Wikipedia page](https://en.wikipedia.org/wiki/ISO_4217#cite_note-divby5-9).

## Usage
The `Currencies` module exports the `Monetary` type. To access currencies, use the `@usingcurrencies` macro. Basic operation is as follows:

    @usingcurrencies USD
    1USD + 2USD  # 3.00 USD
    3 * 1.5USD   # 4.50 USD

Mixed arithmetic is not supported:

    @usingcurrencies USD, CAD
    10USD + 3CAD  # MethodError

Monetary amounts can be compared:

    @usingcurrencies USD, EUR
    1USD < 2USD        # true
    sort([2EUR, 1EUR]) # [1EUR, 2EUR]

Certain useful computations are exported by default:

    @usingcurrencies GBP
    presentvalue = 5000GBP
    annualinterest = 0.02
    investmentyears = 20
    futurevalue = compoundfv(presentvalue, annualinterest, investmentyears)
