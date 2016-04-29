Baskets
=======

The :class:`Basket` type is similar to a multiset or bag in terms of how it
operates. The most convenient constructor takes a list of :class:`Monetary` or
other :class:`Basket` values::

  julia> @usingcurrencies USD, CAD
  julia> Basket([10USD, 2CAD])
  2-currency Currencies.Basket:
   10.00 USD
   2.00 CAD

For Arithmetic
--------------

The basket types support arithmetic with all kinds of currencies, just like
plain :class:`Monetary` values do::

  julia> basket = Basket([10USD, 20CAD])
  2-currency Currencies.Basket:
   10.00 USD
   20.00 CAD

  julia> basket + 3USD
  2-currency Currencies.Basket:
   13.00 USD
   20.00 CAD

  julia> basket * 2
  2-currency Currencies.Basket:
   20.00 USD
   40.00 CAD

As a Collection
---------------

They can also be iterated over, as if they were an array of :class:`Monetary`
values::

  julia> for m in basket
           println(m)
         end
  10.0USD
  20.0CAD

Note that the iteration order is undefined. Baskets support indexing notation,
using a currency symbol as the index::

  julia> basket[:USD]
  10.00 USD

Mutation
--------

Baskets can also be mutated. They can be updated to modify currency weights or
to add new currencies. In many ways, :class:`Basket` objects behave like
dictionaries::

  julia> dyn = Basket([100USD, 200CAD])
  julia> push!(dyn, 100USD)
  2-currency Currencies.Basket:
   200.00 USD
   200.00 CAD

  julia> dyn[:CAD] = -1CAD
  julia> dyn
  2-currency Currencies.Basket:
   200.00 USD
   −1.00 CAD
