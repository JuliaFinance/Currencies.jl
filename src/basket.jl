"""
A collection of `Monetary` values of various currencies. This is an abstract
type; if an immutable variant is desired, use `StaticBasket`, and if a mutable
one is desired, use `DynamicBasket`.
"""
abstract Basket <: AbstractMonetary

# helper method
iszero(x) = x == zero(x)

# build monetary table
typealias SMDict Dict{Symbol, Monetary}
function buildtable_one!(table::SMDict, m::Monetary)
    if haskey(table, currency(m))
        table[currency(m)] += m
    else
        table[currency(m)] = m
    end
    table
end
buildtable_one!(table::SMDict, b::Basket) = buildtable!(table, b)
buildtable!(table::SMDict, ms) = foldl(buildtable_one!, table, ms)
buildtable(ms) = buildtable!(SMDict(), ms)

# basket constructors
macro basketinnerconstructor(sym)
    :($sym(ms::Union{AbstractArray,Tuple}) = new(buildtable(ms))) |> esc
end

macro basketouterconstructor(sym)
    quote
        $sym() = $sym(())
        Base.convert(::Type{$sym}, m::Monetary) = $sym([m])
        Base.convert(::Type{$sym}, b::Basket) = $sym(collect(b))
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
    table::Dict{Symbol, Monetary}
    @basketinnerconstructor StaticBasket
end
@basketouterconstructor StaticBasket

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
    table::Dict{Symbol, Monetary}
    @basketinnerconstructor DynamicBasket
end
@basketouterconstructor DynamicBasket

# access methods (for all baskets)
function Base.length(b::Basket)
    acc = 0
    for _ in b
        acc += 1
    end
    acc
end
Base.haskey(b::Basket, k) = haskey(b.table, k) && !iszero(b.table[k])
Base.getindex(b::Basket, T::Symbol) = get(b.table, T, zero(Monetary{T}))
Base.start(b::Basket) = start(b.table)
function Base.next(b::Basket, s)
    (k, v), s = next(b.table, s)
    if iszero(v)
        next(b, s)
    else
        v, s
    end
end
function Base.done(b::Basket, s)
    if done(b.table, s)
        true
    else
        (k, v), s = next(b.table, s)
        iszero(v) && done(b, s)
    end
end

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
end
function Base.push!(b::DynamicBasket, m::Monetary)
    b[currency(m)] += m
    b
end
function Base.push!(b::DynamicBasket, c::Basket)
    for m in c
        b[currency(m)] += m
    end
    b
end

# other methods (eltype, iszero, zero, ==)
iszero(b::Basket) = isempty(b)
Base. =={T<:AbstractMonetary,U<:AbstractMonetary}(b::T, c::U) = iszero(b - c)
Base. =={T<:Basket,U<:Basket}(b::T, c::U) = iszero(b - c)

const EMPTY_BASKET = StaticBasket()
Base.zero(::Type{StaticBasket}) = EMPTY_BASKET
Base.zero(::Type{DynamicBasket}) = DynamicBasket()
Base.eltype{T<:Basket}(::Type{T}) = Monetary
