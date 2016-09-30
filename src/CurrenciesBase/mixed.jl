# Mixed precision monetary arithmetic

# Promote to larger type if precision same
function Base.promote_rule{A,B,C,D}(
        ::Type{Monetary{A,B,D}},
        ::Type{Monetary{A,C,D}})
    Monetary{A, promote_type(B, C), D}
end

# Promote to BigInt if precision different
function Base.promote_rule{A,B,C,D,E}(
        ::Type{Monetary{A,B,D}},
        ::Type{Monetary{A,C,E}})
    Monetary{A, BigInt, max(D, E)}
end

# Convert with same kind of currency
function Base.convert{A,B,C,D,E}(::Type{Monetary{A,B,C}}, m::Monetary{A,D,E})
    val = if C ≥ E
        convert(B, m.val * big(10)^(C - E))
    else
        sf = big(10)^(E - C)
        q, r = divrem(m.val, sf)
        if r ≠ 0
            throw(InexactError())
        else
            convert(B, q)
        end
    end
    Monetary{A,B,C}(val)
end

Base.isless{T}(m::Monetary{T}, n::Monetary{T}) = isless(promote(m, n)...)
+{T}(m::Monetary{T}, n::Monetary{T}) = +(promote(m, n)...)
/{T}(m::Monetary{T}, n::Monetary{T}) = /(promote(m, n)...)

for fns in DIVS
    for fn in fns
        @eval function Base.$(fn){T}(m::Monetary{T}, n::Monetary{T})
            $(fn)(promote(m, n)...)
        end
    end
end
