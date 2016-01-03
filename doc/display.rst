Display & Format
================

Quick Display
-------------

There are two basic ways to display a :class:`Monetary` value. The
representation used by :func:`show` and :func:`print` is the same, and is fairly
compact. For a richer display, use :func:`writemime`, which has a more
user-friendly representation. To get the :func:`writemime` representation into a
string, use the :func:`stringmime` function::

  julia> stringmime("text/plain", 100USD)
  "100.00 USD"

When a richer representation than ``text/plain`` is available, such as in an
IJulia environment, :class:`Basket` and :class:`Monetary` objects can render
as LaTeX and Markdown, respectively::

  julia> writemime(STDOUT, "text/latex", 100USD)
  $100.00\,\mathrm{USD}$

  julia> writemime(STDOUT, "text/markdown", StaticBasket([100USD, 100EUR]))
  $2$-currency `Currencies.StaticBasket`:

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

Currently, the available styles are: :code:`:finance`, :code:`:us`,
:code:`:european`, :code:`:local`, and :code:`:brief`. The :code:`local` style
attempts to use the convention in the majority of areas where the particular
currency is used. The :code:`:us`, :code:`:european`, and :code:`:local` styles
conflict and cannot be used together. A :code:`:latex` style is provided to make
formatting work nicely in LaTeX math mode, and a :code:`:plain` style (which has
no requirements) is also provided for consistency.
