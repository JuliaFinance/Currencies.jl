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
