# Custom Currencies

Sometimes it is desirable to use a currency that lacks a ISO 4217 code, usually
because it is not yet recognized by the ISO committee. These currencies are not
supported by default. However, if your application requires them, there is a
means to register new currencies.

This package exports `newcurrency!(symb, name, exponent) <newcurrency!>`, and a
convenience macro `@usingcustomcurrency`. As convention, and to prevent name
clashes with ISO 4217 currencies, all custom currencies should use lowercase
letters (all default currencies use only uppercase letters). Note that the
registration of a custom currency is global, so ensure that your application
does not register the same currency as a package that your application depends
on:

```@repl custom
using Currencies  # hide
@usingcustomcurrency xbt "Bitcoin" 8
10xbt
pts = newcurrency!(:pts, "Points", 0)
10pts
```

Supposing that your application needs to handle any `Monetary` values, you may
sometimes need to access the name or description of a currency, custom or not.
This human-readable English-language description is exposed through the
`currencyinfo` function, which takes either a currency symbol, a `Monetary`
type, or a `Monetary` object:

```@repl custom
currencyinfo(:USD)
```

Be aware that custom currencies, in this form, are not intended for arbitrary
creation of vast numbers of currencies on the fly. Due to global state, you must
take care that the currencies you register do not interfere with default
currencies or with some other package. A better and more robust system for
custom currency creation may be possible by leveraging Julia's type system, but
this will not be supported until a future version.
