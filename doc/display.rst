Displaying Currencies
=====================

There are two ways to display a :class:`Monetary` value. The representation used
by :func:`show` and :func:`print` is the same, and is fairly compact. For a
richer display, use :func:`writemime`, which has a more user-friendly
representation. To get the :func:`writemime` representation into a string, use
the :func:`sprint` function::

  julia> sprint(writemime, "text/plain", 100USD)
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
