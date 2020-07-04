# Currencies.jl

[travis-url]:   https://travis-ci.org/JuliaFinance/Currencies.jl
[travis-s-img]: https://travis-ci.org/JuliaFinance/Currencies.jl.svg
[travis-m-img]: https://travis-ci.org/JuliaFinance/Currencies.jl.svg?branch=main

[![][travis-s-img]][travis-url] [![][travis-m-img]][travis-url] 

This package provides bare singleton types based on the standard ISO 4217 3-character alpha codes to be used primarily for dispatch in other JuliaFinance packages together with five methods:

- `currency`: The singleton type for a particular currency symbol
- `symbol`: The 3-character symbol of the currency.
- `name`: The full name of the currency.
- `code`: The ISO 4217 code for the currency.
- `unit`: The minor unit, i.e. number of decimal places, for the currency.

Within JuliaFinance, currencies are defined in two separate packages:

- [Currencies.jl](https://github.com/JuliaFinance/Currencies.jl)
- [Assets.jl](https://github.com/JuliaFinance/Assets.jl)

A brief explanation and motivation for each is presented below.

## [Currencies.jl](https://github.com/JuliaFinance/Currencies.jl)

As mentioned, this package defines standard currencies as singleton types that can be thought of as labels.

For example:

```julia
julia> using Currencies

julia> currency(:USD)
Currency{:USD}

julia> for ccy in currency.([:USD, :EUR, :JPY, :IQD])
            println("Currency: $(Currencies.symbol(ccy))")
            println("Name: $(Currencies.name(ccy))")
            println("Code: $(Currencies.code(ccy))")
            println("Minor Unit: $(Currencies.unit(ccy))\n")
        end

Currency: USD
Name: US Dollar
Code: 840
Minor Unit: 2

Currency: EUR
Name: Euro
Code: 978
Minor Unit: 2

Currency: JPY
Name: Yen
Code: 392
Minor Unit: 0

Currency: IQD
Name: Iraqi Dinar
Code: 368
Minor Unit: 3
```

If all you need is a list of currencies with names, ISO 4217 codes and minor units, e.g. for building a dropdown menu in a user interface, then this lightweight package is what you want.

## [Assets.jl](https://github.com/JuliaFinance/Assets.jl)

When a currency is thought of as a financial instrument (as opposed to a mere label), we choose to refer to it as "Cash" as it would appear, for example, in a balance sheet. [Assets.jl](https://github.com/JuliaFinance/Assets.jl) provides a `Cash` instrument together with a specialized `Position` type that allows for basic algebraic manipulations of `Cash` and other financial instrument positions, e.g.

```julia
julia> import Assets: USD, JPY

julia> 10USD
10.00USD

julia> 10JPY
10JPY

julia> 10USD+20USD
30.00USD

julia> 10USD+10JPY
ERROR: Can't add Positions of different Instruments USD, JPY
```

If you need currency as an asset with corresponding cash positions, you want [Assets.jl](https://github.com/JuliaFinance/Assets.jl).

## Data Source

Data for this package was obtained from https://datahub.io/core/country-codes.
