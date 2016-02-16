"""
A collection of `Monetary` values of various currencies. This is an abstract
type; if an immutable variant is desired, use `StaticBasket`, and if a mutable
one is desired, use `DynamicBasket`.
"""
abstract Basket <: AbstractMonetary

# helper methods
iszero(x) = x == zero(x)
function deleteifzero!{T}(d::Associative{T}, k)
    if iszero(d[k])
        delete!(d, k)
    end
    d
end

# build monetary table
typealias SMDict Dict{Symbol, Monetary}
function buildtable!(table::SMDict, m::Monetary)
    cur = currency(m)
    if haskey(table, cur)
        table[cur] += m
    else
        table[cur] = m
    end
    deleteifzero!(table, cur)
end
buildtable!(table::SMDict, m::Number) =
    throw(ArgumentError("Numbers not supported in Baskets"))
buildtable!(table::SMDict, ms) = foldl(buildtable!, table, ms)
buildtable(ms) = buildtable!(SMDict(), ms)

# basket constructors
macro definebasket(sym)
    quote
        table::SMDict
        $sym(ms::Union{AbstractArray,Tuple}) = new(buildtable(ms))
    end |> esc
end

"""
An immutable collection of `Monetary` values of various currencies. Like
regular `Monetary` values, `StaticBasket` values support basic arithmetic
operations, with both other baskets and with raw monetary values. The
constructor for `StaticBasket` accepts either a monetary value or a vector of
monetary values.

    basket = StaticBasket([1USD, 5EUR])  # \$1 + 5€
    basket += 2EUR                       # \$1 + 7€
    basket \*= 2                          # \$2 + 14€

`StaticBasket` values also support iteration. The iteration order of currencies
is undefined. For instance, the following will print `1.00 USD` and `5.00 EUR`,
in some order. Iteration will skip over any currencies with zero weight in the
basket.

    for amt in StaticBasket([1USD, 5EUR])
        println(amt)
    end
"""
immutable StaticBasket <: Basket
    @definebasket StaticBasket
end

"""
A mutable collection of `Monetary` values of various currencies. `DynamicBasket`
values support all operations on `StaticBasket` values, in addition to the
ability to mutate the basket with index notation, or with `push!`. There is no
other difference between the two types, and they are constructed in the same
way.

    basket = DynamicBasket([1USD, 2EUR])
    basket[:USD] = 3USD  # DynamicBasket([3USD, 2EUR])
    push!(basket, 10GBP) # DynamicBasket([3USD, 2EUR, 10GBP])
"""
immutable DynamicBasket <: Basket
    @definebasket DynamicBasket
end

# basket outer constructors
Base.call{T<:Basket}(::Type{T}) = T(())
Base.convert{T<:Basket}(::Type{T}, m::AbstractMonetary) = T((m,))

# access methods (for all baskets)
Base.length(b::Basket) = length(b.table)
Base.haskey(b::Basket, k) = haskey(b.table, k) && !iszero(b.table[k])
Base.getindex(b::Basket, T::Symbol) = get(b.table, T, zero(Monetary{T}))
Base.start(b::Basket) = start(b.table)
function Base.next(b::Basket, s)
    (_, v), s = next(b.table, s)
    v, s
end
Base.done(b::Basket, s) = done(b.table, s)

# arithmetic methods (for static & dynamic baskets)
Base.promote_rule(::Type{DynamicBasket}, ::Type{StaticBasket}) = DynamicBasket
Base.promote_rule{T<:Basket, U<:Monetary}(::Type{T}, ::Type{U}) = T

Base. +{T<:Basket}(b::T, c::T) = T([collect(b); collect(c)])
Base. +{T<:AbstractMonetary,U<:AbstractMonetary}(b::T, c::U) =
    +(promote(b, c)...)
Base. -{T<:Basket}(b::T) = T([-x for x in b])
Base. -{T<:AbstractMonetary,U<:AbstractMonetary}(b::T, c::U) = b + (-c)
Base. *{T<:Basket}(b::T, k::Real) = T([x * k for x in b])
Base. *{T<:Basket}(k::Real, b::T) = T([k * x for x in b])
Base. /{T<:Basket}(b::T, k::Real) = T([x / k for x in b])

# methods for dynamic baskets
function Base.setindex!(b::DynamicBasket, m::Monetary, k::Symbol)
    @assert currency(m) == k "Monetary value type does not match currency"
    b.table[k] = m
    deleteifzero!(b.table, k)
    m
end
function Base.push!(b::DynamicBasket, m::Monetary)
    b[currency(m)] += m
    b
end

# this method is here only for consistency with the constructor
# probably add! is a better name for all these methods, but arguably push!
# is not a pun.
Base.push!(b::DynamicBasket, c::Basket) = foldl(push!, b, c)

# other methods (eltype, iszero, zero, ==)
iszero(b::Basket) = isempty(b)
Base. =={T<:Basket,U<:AbstractMonetary}(b::T, c::U) = iszero(b - c)
Base. =={T<:AbstractMonetary,U<:Basket}(b::T, c::U) = c == b

const EMPTY_BASKET = StaticBasket()
Base.zero(::Type{StaticBasket}) = EMPTY_BASKET
Base.zero(::Type{DynamicBasket}) = DynamicBasket()
Base.eltype{T<:Basket}(::Type{T}) = Monetary
