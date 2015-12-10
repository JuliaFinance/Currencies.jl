Installation & Usage
====================

In Julia, execute::

  Pkg.add("Currencies")

Then in your project (or in the REPL), use the package with::

  using Currencies

At this point you can import the currency symbols that you will need. Using the
ISO 4217 codes, write::

  @usingcurrencies USD, EUR, GBP

Basic usage of this package is quite simple. For example, for a simple sum of
:class:`Monetary` values, we can write::

  subtotal = 100USD
  tax = 10USD
  total = subtotal + tax

The usual arithmetic operators are available.

Creating :class:`Monetary` Values
---------------------------------

Although using :func:`@usingcurrencies` is the best and most idiomatic method of
creating :class:`Monetary` values, there are several others, some more flexible
than others::

  julia> Monetary(:USD)
  1.00 USD

  julia> Monetary(:USD; precision=4)
  1.0000 USD

  julia> Monetary(:USD; storage=BigInt)
  1.00 USD

  julia> one(Monetary{:USD})
  1.00 USD

  julia> zero(Monetary{:USD})
  0.00 USD

  julia> Monetary(:USD, 0)
  0.00 USD

  julia> Monetary(:USD, 314)
  3.14 USD

Note in particular that last one! The second argument to :class:`Monetary`, if
provided, should be an integer value. Avoid this constructor if possible.

.. warning::

   Custom precisions and storage representations work fine if they're
   consistently used. But if they're ever used in conjunction alongside the
   default versions of the same currency, undesirable behavior will result.
   Stick to the defaults if you do not need more precision.
