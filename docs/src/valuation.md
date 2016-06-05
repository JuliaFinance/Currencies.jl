# Valuation

One important operation on monetary amounts is the ability to valuate them. Both
baskets and single `Monetary` objects can be "converted" (in some sense) to a
reference currency using the `valuate` function. This function takes some table
mapping currency symbols to a simple floating point, which represents its value
to some particular reference. It uses the table to compute the ratio between any
two currencies that are both in the table, and then reduces each currency
present in the basket into the desired basis currency. An example would explain
it better than any words:

```@repl
using Currencies  # hide
@usingcurrencies USD, JPY, EUR;
usdmoney = 100USD;
mybasket = Basket([100USD, 100JPY, 100EUR]);
rates = ExchangeRateTable(
        :USD => 1.0,
        :JPY => 0.02,
        :EUR => 1.2);

valuate(rates, :EUR, usdmoney)
valuate(rates, :JPY, mybasket)
```

The `ExchangeRateTable` type is a provided type that acts very similarly to a
dictionary. In fact, passing a plain dictionary to `valuate` would work too.

## Using the Internet

Often, it isn't practical to provide the data into the program itself. In these
cases, it is helpful to download reputable data from the Internet. If an
Internet connection is available, this package provides the `ecbrates` function,
which gets some recent exchange rate data provided by the European Central Bank,
using the [fixer.io](https://fixer.io/) API:

```julia
@usingcurrencies USD, JPY
usdmoney = 100USD
valuate(ecbrates(), :EUR, usdmoney)  # 12299 JPY (results may vary)
```

This data is not live and may be delayed several days, but for most currencies
and for most uses it is acceptably recent. The available precision is around
five decimal digits, which is more than enough for most applications.

If rates at some point in the past are desired, the `ecbrates` function
accepts an optional parameter with the date:

```julia
julia> valuate(ecbrates(Date(2015, 08, 05)), :EUR, 100USD)
91.89 EUR
```

## Similar Type Conversions

For type safety reasons, `Monetary` objects of the same currency may be
incompatible if stored with different precision or with a different internal
representation. `valuate` provides an explicit, if cumbersome, way to convert
between these incompatible types:

```@repl
valuate(Dict(:USD => 1.0), Monetary{:USD, BigInt, 4}, 100USD)
```

Type conversions and exchange rate valuations can be done at the same time too::

```julia
julia> mycash = 200Monetary(:EUR; storage=BigInt, precision=4)
200.0000 EUR

julia> valuate(ecbrates(), Monetary{:USD, Int, 4}, mycash)
218.8600 USD
```
