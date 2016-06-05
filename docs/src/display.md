# Display & Formatting

## Quick Display

The representation used by `show` and `print` is the same, and is fairly
compact. (Note that this behaviour is retained for compatibility and will likely
change in the future.)

```@repl disp
using Currencies  # hide
@usingcurrencies USD  # hide
show(100USD)
```

When a richer representation than `text/plain` is available, such as in an
IJulia environment, `Basket` and `Monetary` objects can render as LaTeX and
Markdown, respectively:

```@repl disp
show(STDOUT, "text/latex", 100USD)
show(STDOUT, "text/markdown", Basket([100USD, 100EUR]))
```

## Formatting

This package provides powerful formatting for `Monetary` values, but at the
present time not all of this functionality is exposed to the user. However, a
convenient interface is provided to use some of that functionality: the `format`
function. By default, it formats currency in a way acceptable to people who work
with finance:

```@repl disp
format(100USD)
format(-100USD)
```

Extra information about the style desired can be provided in the :obj:`styles`
keyword argument:

```@repl disp
format(1270USD; styles=[:us, :brief])
format(-700EUR; styles=[:european, :finance])
```

Currently, the available general styles are `:finance` and `:brief`. The
`finance` style formats negative numbers in a way familiar to accountants. The
`brief` style enforces shorter symbols and reduced spacing.

The available local styles are `:us`, `:european`, `indian`, `:local`. The
`local` style attempts to use the convention in the majority of areas where the
particular currency is used. Local styles almost certainly conflict, and at most
one of these can be used at once.

A `:latex` style is provided to make formatting work nicely in LaTeX math mode,
and a `:plain` style (which has no requirements) is also provided for
consistency.
