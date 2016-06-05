# Baskets

The `Basket` type is similar to a multiset or bag. The most convenient
constructor takes a list of `Monetary` or other `Basket` values:

```@repl basket
using Currencies  # hide
@usingcurrencies USD, CAD
Basket([10USD, 2CAD])
```

## Arithmetic

The basket types support arithmetic with all kinds of currencies, just like
plain `Monetary` values do:

```@repl basket
basket = Basket([10USD, 20CAD])
basket + 3USD
basket * 2
```

## Collection-like Behaviour

They can also be iterated over, as if they were an array of `Monetary` values:

```@repl basket
for m in basket
   println(m)
end
```

Note that, as with Julia `Dict`s, the iteration order is undefined.

Baskets also support indexing notation, using a currency symbol as the index:

```@repl basket
basket[:USD]
```

## Mutation

Baskets can also be mutated. They can be updated to modify currency weights or
to add new currencies. In many ways, `Basket` objects behave like dictionaries:

```@repl basket
dyn = Basket([100USD, 200CAD])
push!(dyn, 100USD)
dyn[:CAD] = -1CAD
dyn
```
