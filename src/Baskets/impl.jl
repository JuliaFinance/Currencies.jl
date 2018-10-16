# helper methods
iszero(x) = x == zero(x)
function deleteifzero!(d::AbstractDict{T}, k) where T
    if iszero(d[k])
        delete!(d, k)
    end
    d
end

# build monetary table
const SMDict = Dict{Symbol, Monetary}
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
buildtable!(table::SMDict, ms) = foldl(buildtable!, ms; init=table)
buildtable(ms) = buildtable!(SMDict(), ms)
