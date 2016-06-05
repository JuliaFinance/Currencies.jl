# Installation & Usage

In Julia, execute:

```julia
Pkg.add("Currencies")
```

Then in your project (or in the REPL), use the package with:

```julia
using Currencies
```

At this point you can import the currency symbols that you will need. Using the
ISO 4217 codes, write:

```julia
@usingcurrencies USD, EUR, GBP
```

Basic usage of this package is quite simple. For example, for a simple sum of
`Monetary` values, we can write:

```@example
using Currencies  # hide
@usingcurrencies USD  # hide
subtotal = 100USD
tax = 10USD
total = subtotal + tax
```

The usual arithmetic operators are available.

## Creating `Monetary` Values

Although using `@usingcurrencies` is the best and most idiomatic method of
creating `Monetary` values, there are several others, some more flexible than
others:

```julia
julia> Monetary(:USD)
1.00 USD

julia> Monetary(:USD; precision=4)
1.0000 USD

julia> Monetary(:USD; storage=BigInt)
1.00 USD

julia> zero(Monetary{:USD})
0.00 USD

julia> Monetary(:USD, 0)
0.00 USD

julia> Monetary(:USD, 314)
3.14 USD

julia> Monetary{:USD, Int, 4}(10000)
1.0000 USD
```

Note in particular that last two! The second argument to `Monetary`, if
provided, should be an integer value, and similarly the argument to the inner
constructor is also expected to be an integer. These constructors can be
difficult to understand and should be avoided where possible.

!!! warning
    Custom precisions and storage representations work fine if they're
    consistently used. But if they're ever used in conjunction alongside the
    default versions of the same currency, undesirable behavior may result.
    Stick to the defaults if you do not need more precision.

## Caution with `one`

Note that the `one` method returns the multiplicative identity. For currencies,
this identity does not have a unit. That means that the type `one` returns may
be unintuitive:

```julia
julia> one(Monetary{:USD})
1
```
