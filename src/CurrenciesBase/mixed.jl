# Mixed precision monetary arithmetic

# Promote to larger type if precision same
function Base.promote_rule(
        ::Type{Monetary{A,B,D}},
        ::Type{Monetary{A,C,D}}) where {A,B,C,D}
    Monetary{A, promote_type(B, C), D}
end

# Promote to BigInt if precision different
function Base.promote_rule(
        ::Type{Monetary{A,B,D}},
        ::Type{Monetary{A,C,E}}) where {A,B,C,D,E}
    Monetary{A, BigInt, max(D, E)}
end

# Convert with same kind of currency
function Base.convert(::Type{Monetary{A,B,C}}, m::Monetary{A,D,E}) where {A,B,C,D,E}
    Monetary{A,B,C}(m.val)
end

Base.isless(m::Monetary{T}, n::Monetary{T}) where {T} = isless(promote(m, n)...)
+(m::Monetary{T}, n::Monetary{T}) where {T} = +(promote(m, n)...)
/(m::Monetary{T}, n::Monetary{T}) where {T} = /(promote(m, n)...)

for fns in DIVS
    for fn in fns
        @eval function Base.$(fn)(m::Monetary{T}, n::Monetary{T}) where T
            $(fn)(promote(m, n)...)
        end
    end
end
