Baskets
=======

The :class:`StaticBasket` and :class:`DynamicBasket` types are similar to
multisets or bags in terms of how they operate. The most convenient constructor
takes a list of :class:`Monetary` or other :class:`Basket` values::

  julia> @usingcurrencies USD, CAD
  julia> StaticBasket([10USD, 2CAD])
  2-currency Currencies.StaticBasket:
   10.00 USD
   2.00 CAD

The basket types support arithmetic with all kinds of currencies::

  julia> basket = StaticBasket([10USD, 20CAD])
  2-currency Currencies.StaticBasket:
   10.00 USD
   20.00 CAD

  julia> basket + 3USD
  2-currency Currencies.StaticBasket:
   13.00 USD
   20.00 CAD

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
