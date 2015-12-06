Performance
===========

This package abstracts the currency as part of the type, and not part of this
value. This allows for increased performance, at some compile-time cost. For
each currency, each arithmetic operation used on that currency incurs some small
one-time cost.
