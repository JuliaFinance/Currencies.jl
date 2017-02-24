# Rounding

Although the goal of this package is to provide integer operations on monetary
amounts, in practice, decimal operations are unavoidable. For instance, there is
no good way to compute interest or commissions with just integer arithmetic. By
default, this package enables multiplying and dividing `Basket` and `Monetary`
objects with all numbers descending from `Real`, including floating points. In
fact, the recommended way to construct `Monetary` objects is by implicit
floating point multiplication. This isn't a problem unless the floating point
numbers are so big that floating points lose precision::

```julia
@usingcurrencies USD
90071992547409.91USD  # 90071992547409.91 USD
90071992547409.92USD  # 90071992547409.92 USD
90071992547409.93USD  # 90071992547409.94 USD (!!)
```

If you intend to use numbers of that size, and you actually care about the very
small relative error, then there are several solutions::

```julia
@usingcurrencies USD
parse(BigFloat, "90071992547409.93")USD  # 90071992547409.93 USD
Monetary(:USD, 9007199254740993)         # 90071992547409.93 USD
```

Multiplication by arbitrary reals is useful, but there are some caveats.
Firstly, be aware of rounding. By default, this package rounds to the nearest
smallest denomination. Normally, this is not a problem. These rounding errors
can pile up over time, however. Consider the following example:

```julia
@usingcurrencies USD
a = π * USD    # 3.14 USD
b = π * a      # 9.86 USD
c = π^2 * USD  # 9.87 USD (!!)
```

There is no single way to fix this problem, because depending on the situation
that you want to model, the solution is different. One thing that helps in some
circumstances is being able to specify the rounding method, or being able to do
the calculations yourself. This package provides only the most useful rounding
method, which is Julia's built-in `round`. To do a different rounding method,
you must perform the calculations yourself, on a real type of your choice, by
temporarily "taking apart" the data, and converting it back when it needs to be
rounded (note that here, you're in charge of how to round the data). For
example:

```julia
@usingcurrencies USD
money = 1USD                     # 1 USD
magn = money.val                 # 1.00
symb = currency(money)           # :USD
a = π^2 * magn                   # 9.86960440...
Monetary(symb, round(Int, 100a)) # 9.87 USD
```

!!! warning
    The `.val` field access is expected to be deprecated in the future. It is
    highly recommended that it not be used. A better replacement will become
    available in the future.

## Custom Precision

The default precision for most currencies is down to the minor currency unit.
For example, for the United States dollar, this minor currency unit is the cent.
This is acceptable for most purposes, but in some situations more or less
precision is necessary. The precision (the number of decimal points after the
major currency unit) can be controlled as a third type parameter to `Monetary`:

```@repl mixed
using Currencies  # hide
USD_M = Monetary{:USD, Int, 3}(1000)
julia> 10USD_M + 11.004USD_M
```

Sometimes it is useful to override the second parameter too, to change the
underlying storage precision:

```@repl mixed
USD_M = Monetary{:USD, Int128, 3}(1000)
1267650600228229401496703205376USD_M
```

Mixed arithmetic between precisions and representations is supported. However,
it's important to note that mixed arithmetic may have significant performance
implications. This is because for type safety, many combinations are converted
unnecessarily to `BigInt` as an internal representation:

```@repl mixed
USD_M + USD
dump(ans)
```

In some situations, it may be better to implement these conversions manually.

## Special Metals

Some "currencies", like XAU (gram of gold), have no sensible minor unit. For
these currencies, the precision must be provided manually:

```julia
julia> @usingcurrencies XAU
ERROR: ArgumentError: Must provide precision for currency XAU.
 in Monetary at ~/.julia/v0.5/Currencies/src/monetary.jl:47
 in eval at ./boot.jl:263

julia> const XAU = Monetary(:XAU; precision=4)
 1.0000 XAU
```

The usual caveats apply—be careful not to mix two different precisions of this
currency. Otherwise, it can now be used like any other currency.
