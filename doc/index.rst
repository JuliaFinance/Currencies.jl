.. Currencies.jl documentation master file, created by
   sphinx-quickstart on Thu Dec  3 11:13:32 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Currencies.jl
=============

This package provides a simple interface to using a wide variety of currencies
with checked arithmetic in Julia. While floating point arithmetic is very
convenient for currency computations, there are common problems with using
floating point comparisons. This package addresses those issues by treating
monetary amounts as fixed-point decimals.

Installation & Usage
--------------------

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

Displaying Currencies
---------------------

There are two ways to display a :class:`Monetary` value, :func:`show` and
:func:`print`. The representation used by :func:`print` is more compact, but the
representation used by :func:`show` is more user-friendly. To get the
:func:`show` representation into a string, use the :func:`sprint` function::

  sprint(show, 100USD)  # "100.00 USD"

Baskets
-------

The :class:`StaticBasket` and :class:`DynamicBasket` types are similar to
multisets or bags in terms of how they operate.

Contents
--------

.. toctree::
   :maxdepth: 2

   rounding



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
