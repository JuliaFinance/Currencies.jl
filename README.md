# Currencies.jl

[![Join the chat at https://gitter.im/JuliaFinance/Currencies.jl](https://badges.gitter.im/JuliaFinance/Currencies.jl.svg)](https://gitter.im/JuliaFinance/Currencies.jl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/JuliaFinance/Currencies.jl.svg?branch=master)](https://travis-ci.org/JuliaFinance/Currencies.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/bghtp8yj8sma24kd?svg=true)](https://ci.appveyor.com/project/JuliaFinance/currencies-jl)
[![Coverage Status](https://coveralls.io/repos/JuliaFinance/Currencies.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaFinance/Currencies.jl?branch=master)
[![codecov](https://codecov.io/gh/JuliaFinance/Currencies.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaFinance/Currencies.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliafinance.github.io/Currencies.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://juliafinance.github.io/Currencies.jl/latest)

## Purpose
This package provides a simple interface to using a wide variety of currencies with performant checked arithmetic in Julia. Creating and using monetary values is clean and easy. For advanced users, it also offers rich formatting and other powerful features, such as integration with currency conversion APIs.

## Data Source
The currency-related information for this package comes from [this Wikipedia page](https://en.wikipedia.org/wiki/ISO_4217#cite_note-divby5-9), the official ISO standard, and other Wikipedia pages. It is compiled manually and may be in error; please do submit a pull request to correct any errors.

## Usage
This README.md file provides a basic guide to getting started. It is not a replacement for the [documentation](https://JuliaFinance.github.io/Currencies.jl/stable). Please file any corrections or missing parts of the documentation as issues, or even better, send in a pull request.

The `Currencies` module exports the `Monetary` type. To access currencies, use the `@usingcurrencies` macro. Basic operation is as follows:

```julia
@usingcurrencies USD
1USD + 2USD  # 3.00 USD
3 * 1.5USD   # 4.50 USD
```

Mixed arithmetic is not supported:

```julia
@usingcurrencies USD, CAD
10USD + 3CAD  # ArgumentError
```

Monetary amounts can be compared:

```julia
@usingcurrencies USD, EUR
1USD < 2USD        # true
sort([2EUR, 1EUR]) # [1EUR, 2EUR]
```

Baskets, effectively collections of many different currencies, are supported using the `Basket` type. To catch likely errors, `Monetary` objects don't support mixed arithmetic. But if mixed arithmetic is desired, it is still possible by promoting one of the objects to a `Basket` type:

```julia
@usingcurrencies USD, CAD
money = 100USD
basket = Basket(money)  # Basket([100USD])
basket += 20CAD         # Basket([100USD, 20CAD])
```

To access an individual component of a basket, indexing notation is supported.

```julia
@usingcurrencies USD, EUR, GBP
sdr = Basket([1USD, 2EUR, 3GBP])
sdr[:USD] = 3USD
sdr[:GBP]  # 3.00 GBP
```

Because of the nature of holding multiple currencies, some operations are not supported. In particular, one cannot divide baskets by baskets or compare baskets with baskets (equality, however, is still supported). Baskets however can be iterated over to get their components, in undefined order. `Basket` objects additionally support `push!`.

```julia
@usingcurrencies USD, EUR, GBP, JPY
basket = Basket([300USD, 400EUR, 500GBP, 600JPY])
for amount::Monetary in basket
    println(amount)
end
push!(basket, 200USD)
basket[:USD]
```

For convenience, it's possible to add `Basket` values to regular `Monetary` values. But as seen earlier, adding two `Monetary` values does not result in a `Basket` value. If it's desired to combine two values of unknown type (either `Basket` or `Monetary`), the constructor for `Basket` can be used directly:

```julia
@usingcurrencies USD, EUR, GBP
a = Basket([20USD, 20EUR])
b = 10USD
c = Basket([5EUR, 40GBP])
Basket([a, b, c])  # Basket([30USD, 25EUR, 40GBP])
```

Note that for consistency with the constructor, `push!` for `Basket` accepts a `Basket` object as an argument. This is somewhat inconsistent with other containers, which use `append!` or `union!`.

## Using `Monetary` in Practice
`Monetary` types behave a lot like integer types, and they can be used like them for a lot of practical situations. For example, here is a (quite fast) function to give optimal change using the common European system of having coins and bills worth 0.01€, 0.02€, 0.05€, 0.10€, 0.20€, 0.50€, 1.00€, and so forth until 500.00€ (this algorithm doesn't necessarily work for all combinations of coin values).

```julia
@usingcurrencies EUR
COINS = [500EUR, 200EUR, 100EUR, 50EUR, 20EUR, 10EUR, 5EUR, 2EUR, 1EUR, 0.5EUR,
    0.2EUR, 0.1EUR, 0.05EUR, 0.02EUR, 0.01EUR]
function change(amount::Monetary{:EUR,Int})
    coins = Dict{Monetary{:EUR,Int}, Int}()
    for denomination in COINS
        coins[denomination], amount = divrem(amount, denomination)
    end
    coins
end

sum([k*v for (k, v) in change(167.25EUR)])  # 167.25EUR
```

## Valuation
Sometimes it is useful to value a `Basket` or a single `Monetary` value into a different currency, using an exchange rate. One way to do this is with the `valuate` function, and by constructing an `ExchangeRateTable`. An example follows:

```julia
@usingcurrencies USD, CAD, JPY
rates = ExchangeRateTable(
    :USD => 1.0,
    :CAD => 0.7,
    :JPY => 0.02)
valuate(rates, :USD, 100JPY)  # 2.00 USD
```

For more on valuation, as usual, see the [documentation](https://JuliaFinance.github.io/Currencies.jl/stable/valuation).

## Floating Points & Other Reals
Advanced users may be interested in a [cautionary note](https://JuliaFinance.github.io/Currencies.jl/stable/rounding) on rounding.

## Custom Currencies & Names
Advanced users may also be interested in [using currencies](https://JuliaFinance.github.io/Currencies.jl/stable/custom) that are not in ISO 4217.

## Related Packages
Please see [FinancialMarkets.jl](https://github.com/imanuelcostigan/FinancialMarkets.jl) package in case that suits your needs better.
