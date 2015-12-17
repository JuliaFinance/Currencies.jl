# Currencies.jl

[![Build Status](https://travis-ci.org/TotalVerb/Currencies.jl.svg?branch=master)](https://travis-ci.org/TotalVerb/Currencies.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/ofn6irk62gfe5v0o?svg=true)](https://ci.appveyor.com/project/TotalVerb/currencies-jl)
[![Coverage Status](https://coveralls.io/repos/TotalVerb/Currencies.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/TotalVerb/Currencies.jl?branch=master)
[![Documentation Status](https://readthedocs.org/projects/currenciesjl/badge/?version=latest)](http://currenciesjl.readthedocs.org/en/latest/?badge=latest)

## Purpose
Please see [FinancialMarkets.jl](https://github.com/imanuelcostigan/FinancialMarkets.jl) package in case that suits your needs better.

This package provides a much simpler interface to using a wide variety of currencies with performant checked arithmetic in Julia. It provides a clean interface for creating currency objects and manipulating them. It is user-friendly and provides some basic but useful features for calculating investments in the REPL.

## Data Source
The currency-related information for this package comes from [this Wikipedia page](https://en.wikipedia.org/wiki/ISO_4217#cite_note-divby5-9).

## Usage
For a full documentation, [read the docs](http://currenciesjl.readthedocs.org/en/latest/). Please file any corrections or missing parts of the documentation as issues, or even better, send in a pull request. Following is a brief guide to getting started.

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

Certain useful computations are exported by default:

```julia
@usingcurrencies GBP
presentvalue = 5000GBP
annualinterest = 0.02
investmentyears = 20
futurevalue = compoundfv(presentvalue, annualinterest, investmentyears)
```

Baskets, effectively collections of many different currencies, are supported in two variants: `StaticBasket` and `DynamicBasket`, differing only in mutability. To catch likely errors, `Monetary` objects don't support mixed arithmetic. But if mixed arithmetic is desired, it is still possible by promoting one of the objects to a `Basket` type:

```julia
@usingcurrencies USD, CAD
money = 100USD
basket = StaticBasket(money)  # StaticBasket([100USD])
basket += 20CAD               # StaticBasket([100USD, 20CAD])
```

To access an individual component of a basket, indexing notation is supported. Note that only `DynamicBasket` allows `setindex!`.

```julia
@usingcurrencies USD, EUR, GBP
sdr = DynamicBasket([1USD, 2EUR, 3GBP])
sdr[:USD] = 3USD
sdr[:GBP]  # 3.00 GBP
```

Because of the nature of holding multiple currencies, some operations are not supported. In particular, one cannot divide baskets by baskets or compare baskets with baskets (equality, however, is still supported). Baskets however can be iterated over to get their components, in undefined order. `DynamicBasket` objects additionally support `push!`.

```julia
@usingcurrencies USD, EUR, GBP, JPY
basket = DynamicBasket([300USD, 400EUR, 500GBP, 600JPY])
for amount::Monetary in basket
    println(amount)
end
push!(basket, 200USD)
basket[:USD]
```

For convenience, it's possible to add `Basket` values to regular `Monetary` values. But as seen earlier, adding two `Monetary` values does not result in a `Basket` value. If it's desired to combine two values of unknown type (either `Basket` or `Monetary`), the constructors for `StaticBasket` and `DynamicBasket` can be used directly:

```julia
@usingcurrencies USD, EUR, GBP
a = DynamicBasket([20USD, 20EUR])
b = 10USD
c = StaticBasket([5EUR, 40GBP])
StaticBasket([a, b, c])  # StaticBasket([30USD, 25EUR, 40GBP])
```

Note that for consistency with the constructor, `push!` for `DynamicBasket` accepts a `Basket` object as an argument. This is somewhat inconsistent with other containers, which use `append!` or `union!`.

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

For more on valuation, as usual, see the [documentation](http://currenciesjl.readthedocs.org/en/latest/valuation.html).

## Floating Points & Other Reals
Advanced users may be interested in a [cautionary note](http://currenciesjl.readthedocs.org/en/latest/rounding.html) on rounding.

## Custom Currencies & Names
Advanced users may also be interested in [using currencies](http://currenciesjl.readthedocs.org/en/latest/custom.html) that are not in ISO 4217.
