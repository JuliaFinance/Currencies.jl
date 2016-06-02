Display & Format
================

Quick Display
-------------

The representation used by :func:`show` and :func:`print` is the same, and is
fairly compact.

  julia> show(100USD)
  100.0USD

When a richer representation than ``text/plain`` is available, such as in an
IJulia environment, :class:`Basket` and :class:`Monetary` objects can render
as LaTeX and Markdown, respectively::

  julia> show(STDOUT, "text/latex", 100USD)
  $100.00\,\mathrm{USD}$

  julia> show(STDOUT, "text/markdown", Basket([100USD, 100EUR]))
  $2$-currency `Currencies.Basket`:

   - $100.00\,\mathrm{USD}$
   - $100.00\,\mathrm{EUR}$

Formatting
----------

This package provides powerful formatting for :class:`Monetary` values, but at
the present time not all of this functionality is exposed to the user. However,
a convenient interface is provided to use some of that functionality: the
:func:`format` function. By default, it formats currency in a way acceptable to
people who work with finance::

  julia> format(100USD)
  "100.00 USD"

  julia> format(-100USD)
  "(100.00) USD"

Extra information about the style desired can be provided in the :obj:`styles`
keyword argument::

  julia> format(1270USD; styles=[:us, :brief])
  "\$1,270.00"

  julia> format(-700EUR; styles=[:european, :finance])
  (700,00) EUR

Currently, the available general styles are :code:`:finance` and :code:`:brief`.
The :code:`finance` style formats negative numbers in a way familiar to
accountants. The :code:`brief` style enforces shorter symbols and reduced
spacing.

The available local styles are :code:`:us`, :code:`:european`, :code:`indian`,
:code:`:local`. The :code:`local` style attempts to use the convention in the
majority of areas where the particular currency is used. Local styles almost
certainly conflict, and at most one of these can be used at once.

A :code:`:latex` style is provided to make formatting work nicely in LaTeX math
mode, and a :code:`:plain` style (which has no requirements) is also provided
for consistency.
