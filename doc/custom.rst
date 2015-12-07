Custom Currencies
=================

Sometimes it is desirable to use a currency that lacks a ISO 4217 code, usually
because it is not yet recognized by the ISO committee. These currencies are not
supported by default. However, if your application requires them, there is a
means to register new currencies.

This package exports :func:`newcurrency!(symb, name, exponent) <newcurrency!>`,
and a convenience macro :func:`@usingcustomcurrency`. As convention, and to
prevent name clashes with ISO 4217 currencies, all custom currencies should use
lowercase letters (all default currencies use only uppercase letters). Note that
the registration of a custom currency is global, so ensure that your application
does not register the same currency as a package that your application depends
on::

  julia> @usingcustomcurrency xbt "Bitcoin" 8
  julia> 10xbt
  10.00000000 xbt
  julia> pts = newcurrency!(:pts, "Points", 0)
  julia> 10pts
  10 pts

Supposing that your application needs to handle any :class:`Monetary` values,
you may sometimes need to access the name or description of a currency, custom
or not. This human-readable English-language description is exposed through the
:func:`currencyinfo` function, which takes either a currency symbol, a
:class:`Monetary` type, or a :class:`Monetary` object::

  julia> currencyinfo(:USD)
  "United States dollar"

Be aware that custom currencies, in this form, are not intended for arbitrary
creation of vast numbers of currencies on the fly. Due to global state, you must
take care that the currencies you register do not interfere with default
currencies or with some other package. A better and more robust system for
custom currency creation may be possible by leveraging Julia's type system, but
this will not be supported until a future version.
