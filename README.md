# Currencies.jl

[![Build Status](https://travis-ci.org/JuliaFinance/Currencies.jl.svg?branch=master)](https://travis-ci.org/JuliaFinance/Currencies.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/chnj7xc6r0deux92/branch/master?svg=true)](https://ci.appveyor.com/project/EricForgy/currencies-jl/branch/master)

This is a primordial package for the JuliaFinance ecosytem. It provides bare singleton types based on standard ISO 4167 currency codes to be used primarily for dispatch in other JuliaFinance packages together with three methods:

- `name`: The name of the currency.
- `code`: The ISO 4167 code for the currency.
- `unit`: The minor unit, i.e. number of decimal places, for the currency.

For example:
```julia
julia> using Currencies

julia> import Currencies: USD, EUR, JPY, IQD

julia> typeof(USD)
Currency{:USD}

julia> sizeof(USD)
0

julia> for ccy in [USD, EUR, JPY, IQD]
           println("Currency: $(ccy)")
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

In finance, cash and currencies are a suprisingly difficult concept to get right.

Within the JuliaFinance ecosystem, currencies are defined in three packages with increasing complexity:

- [Currencies.jl](https://github.com/JuliaFinance/Currencies.jl)
- [FinancialInstruments.jl](https://github.com/JuliaFinance/FinancialInstruments.jl)
- [Positions.jl](https://github.com/JuliaFinance/Positions.jl)

A brief explanation and motivation for each is presented below.

## [Currencies.jl](https://github.com/JuliaFinance/Currencies.jl)

As mentioned, this package defines standard currencies as primordial singleton types that can be thought of conceptually as mere labels to build further upon. This package has no external dependencies other the Julia standard libraries.

If all you need is a list of currencies with names, ISO 4167 codes and minor units, e.g. for building a user interface, then this lightweight package is what you want.

## [FinancialInstruments.jl](https://github.com/JuliaFinance/FinancialInstruments.jl)

Moving up one notch in complexity, we have FinancialInstruments.jl.

A financial instrument is a tradeable monetary contract that creates an asset for some parties while, at same time, creating a liability for others.

Examples of financial instruments include stocks, bonds, loans, derivatives, etc. However, the most basic financial instruments are currencies.

If currencies are financial instruments, why not make `FinancialInstruments` the most primordial package and `Currencies` could simply extend `FinancialInstruments`?

That is certainly a tempting option, but, as mentioned above, there are use cases for currencies where the fact they are financial instruments is immaterial so it makes sense to have a lightweight primordial `Currencies` without the baggage.

When a currency is thought of as a financial instrument (as opposed to a mere label used in UI component), we choose to refer to it as `Cash` (as it would appear in a balance sheet).

For example:

```julia
julia> using FinancialInstruments

julia> const FI = FinancialInstruments
FinancialInstruments

julia> FI.USD
Cash{Currency{:USD}}()
```

In this case, `Cash` is again a primordial singleton type, but other financial instruments can be `struct`s with various fields.

It is unlikely that as user will need `FinancialInstruments` directly. Rather, `FinancialInstruments` is intended for package developers as the base for building other, more complex, financial instruments.

## [Positions.jl](https://github.com/JuliaFinance/Positions.jl)

Finally, we have `Positions.jl`.

A `Position` represents ownership of a financial instrument including the quantity of that financial instrument. For example, Microsoft stock (MSFT) is a financial instrument. A position could be 1,000 shares of MSFT.

In the case of currency, `FI.USD` would be a financial instrument and owning $1,000 would mean you own 1,000 units of the financial instrument `FI.USD`. Owning 1 unit of a currency, e.g. `FI.USD`, is a special position we denote simply (and with abuse of symbols) as `USD`.

If you are building a financial application that requires adding, subtracting, multiplying and dividing currencies, then you want to use `Positions`.

For example:

```julia
julia> using Positions

julia> import Positions: USD, JPY

julia> USD
1.00 USD

julia> 10USD
10.00 USD

julia> 10USD+20USD
30.00 USD

julia> 5*20USD
100.00 USD

julia> 100USD/5
20.00 USD

julia> 100USD/5USD
FixedDecimal{Int64,2}(20.00)

julia> 100JPY/5JPY
FixedDecimal{Int64,0}(20)

julia> 100USD+100JPY
ERROR: promotion of types Position{Cash{Currency{:USD}},FixedPointDecimals.FixedDecimal{Int64,2}} and Position{Cash{Currency{:JPY}},FixedPointDecimals.FixedDecimal{Int64,0}} failed to change any arguments
```

Note that algebraic operations of currency positions require the positions to be of the same financial instrument. In this case, they must be the same currency as indicated by the error in the last command above.

## Summary

This package provides lightweight primordial definitions of standard currencies. It is intended for direct use only if the additional baggage of currency as a financial instrument is not required.

`FinancialInstruments` is an intermediate package that defines currencies as tradeable financial instruments as well as providing a base for extending to other more complex instruments.

`Positions` is a simple package that defines currency amounts and allows basic algebraic operations on currencies. If you are building a financial application, you probably want `Positions` as opposed to `Currencies`.

See also:

- [Markets.jl](https://github.com/JuliaFinance/Markets.jl)
- [GeneralLedgers.jl](https://github.com/JuliaFinance/GeneralLedgers.jl)

## Data Source

Data for this package was obtained from https://datahub.io/core/country-codes.

