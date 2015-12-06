"""
A collection of `Monetary` values of various currencies. This is an abstract
type; if an immutable variant is desired, use `StaticBasket`, and if a mutable
one is desired, use `DynamicBasket`.
"""
abstract Basket <: AbstractMonetary

# helper method
iszero(x) = x == zero(x)

# build monetary table
function buildtable!(table::Dict{Symbol, Monetary}, ms)
    for m in ms
        if isa(m, Monetary)
            if haskey(table, currency(m))
                table[currency(m)] += m
            else
                table[currency(m)] = m
            end
        elseif isa(m, Basket)
            buildtable!(table, m)
        else
            throw(ArgumentError(
                "Value $m cannot be interpreted as a monetary value."))
        end
    end
    table
end

function buildtable(ms)
    table = Dict{Symbol, Monetary}()
    buildtable!(table, ms)
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
    StaticBasket(ms::AbstractArray) = new(buildtable(ms))
    StaticBasket() = StaticBasket(Monetary[])
end

Base.convert(::Type{StaticBasket}, m::Monetary) = StaticBasket([m])
Base.convert(::Type{StaticBasket}, b::Basket) = StaticBasket(collect(b))

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
    DynamicBasket(ms::AbstractArray) = new(buildtable(ms))
    DynamicBasket() = DynamicBasket(Monetary[])
end

Base.convert(::Type{DynamicBasket}, m::Monetary) = DynamicBasket([m])
Base.convert(::Type{DynamicBasket}, b::Basket) = DynamicBasket(collect(b))

# access methods (for all baskets)
function Base.length(b::Basket)
    acc = 0
    for _ in b
        acc += 1
    end
    acc
end
Base.haskey(b::Basket, k) =
    haskey(b.table, k) && !iszero(b.table[k])
Base.getindex(b::Basket, k::Symbol) = get(b.table, k, zero(Monetary{k}))
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
function Base.show(io::IO, b::Basket)
    write(io, "$(typeof(b))([")
    write(io, join(b, ","))
    print(io, "])")
end
function Base.writemime(io::IO, ::MIME"text/plain", b::Basket)
    len = length(b)
    write(io, "$len-currency $(typeof(b)):")
    for val in b
        write(io, "\n ")
        writemime(io, "text/plain", val)
    end
end

# arithmetic methods (for static & dynamic baskets)
Base.promote_rule(::Type{DynamicBasket}, ::Type{StaticBasket}) = DynamicBasket
Base.promote_rule{T<:Monetary}(::Type{StaticBasket}, ::Type{T}) = StaticBasket
Base.promote_rule{T<:Monetary}(::Type{DynamicBasket}, ::Type{T}) = DynamicBasket

+{T<:Basket}(b::T, c::T) = T([collect(b); collect(c)])
+{T<:AbstractMonetary,U<:AbstractMonetary}(b::T, c::U) = +(promote(b, c)...)
-{T<:Basket}(b::T) = T([-x for x in collect(b)])
-{T<:AbstractMonetary,U<:AbstractMonetary}(b::T, c::U) = b + (-c)
*{T<:Basket}(b::T, k::Real) = T([x * k for x in collect(b)])
*{T<:Basket}(k::Real, b::T) = T([k * x for x in collect(b)])
/{T<:Basket}(b::T, k::Real) = T([x / k for x in collect(b)])

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
    for m in collect(c)
        b[currency(m)] += m
    end
    b
end

# other methods (eltype, iszero, zero, ==)
iszero(b::Basket) = isempty(b)
=={T<:AbstractMonetary,U<:AbstractMonetary}(b::T, c::U) = iszero(b - c)
=={T<:Basket,U<:Basket}(b::T, c::U) = iszero(b - c)

const EMPTY_BASKET = StaticBasket()
Base.zero(::Type{StaticBasket}) = EMPTY_BASKET
Base.zero(::Type{DynamicBasket}) = DynamicBasket()
Base.eltype(::Type{StaticBasket}) = Monetary
Base.eltype(::Type{DynamicBasket}) = Monetary
