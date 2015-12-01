# Currencies

[![Build Status](https://travis-ci.org/TotalVerb/Currencies.jl.svg?branch=master)](https://travis-ci.org/TotalVerb/Currencies.jl)

## Purpose
This package is not intended to replace the excellent [FinancialMarkets.jl](https://github.com/imanuelcostigan/FinancialMarkets.jl) package. Instead, this package provides a much simpler interface to using a wide variety of currencies with checked arithmetic in Julia. The motivation for this package comes from the nasty trap of the relative convenience of using floating point arithmetic for currency computations, combined with the perils of using floating point comparisons. Instead, fixed point decimals should be preferred.

This package provides a clean interface for creating currency objects and manipulating them. It is user-friendly and provides some basic but useful features for calculating investments on the command line.

## Data Source
The currency-related information for this package comes from [this Wikipedia page](https://en.wikipedia.org/wiki/ISO_4217#cite_note-divby5-9).

## Usage
The `Currencies` module exports the `Monetary` type. To access currencies, use the `@usingcurrencies` macro. Basic operation is as follows:

```julia
@usingcurrencies USD
1USD + 2USD  # 3.00 USD
3 * 1.5USD   # 4.50 USD
```

Mixed arithmetic is not supported:

```julia
@usingcurrencies USD, CAD
10USD + 3CAD  # MethodError
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

## Floating Points & Other Reals
Although the goal of this package is to provide integer operations on monetary amounts, in practice, decimal operations are unavoidable. For instance, there is no good way to compute interest or commissions with just integer arithmetic. By default, this package enables multiplying and dividing `Basket` and `Monetary` objects with all numbers descending from `Real`, including floating points. In fact, the recommended way to construct `Monetary` objects is by implicit floating point multiplication. This isn't a problem unless the floating point numbers are so big that floating points lose precision:

```julia
@usingcurrencies USD
90071992547409.91USD  # 90071992547409.91 USD
90071992547409.92USD  # 90071992547409.92 USD
90071992547409.93USD  # 90071992547409.94 USD (!!)
```

If you intend to use numbers of that size, and you actually care about the very small relative error, then there are several solutions:

```julia
@usingcurrencies USD
parse(BigFloat, "90071992547409.93")USD  # 90071992547409.93 USD
Monetary(:USD, 9007199254740993)         # 90071992547409.93 USD
```

Multiplication by arbitrary reals is useful, but there are some caveats. Firstly, be aware of rounding. By default, this package rounds to the nearest smallest denomination. Normally, this is not a problem. These rounding errors can pile up over time, however. Consider the following example:

```julia
@usingcurrencies USD
a = π * USD    # 3.14 USD
b = π * a      # 9.86 USD
c = π^2 * USD  # 9.87 USD (!!)
```

There is no single way to fix this problem, because depending on the situation that you want to model, the solution is different. One thing that helps in some circumstances is being able to specify the rounding method, or being able to do the calculations yourself. This package provides only the most useful rounding method, which is Julia's built-in `round`. To do a different rounding method, you must perform the calculations yourself, on a real type of your choice, by temporarily "taking apart" the data, and converting it back when it needs to be rounded (note that here, you're in charge of how to round the data).

```julia
@usingcurrencies USD
money = 1USD                   # 1 USD
magn = int(money)              # 100
symb = currency(money)         # :USD
a = π * magn                   # 314.159265...
b = π * a                      # 986.960440...
Monetary(symb, round(Int, b))  # 9.87 USD
```
