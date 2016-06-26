module DeclarativeFormatting

using Compat

export FormatRequirement, IncompatibleFormatException, allowable, best,
       takenonzero, conflict, reconcile, FormatSpecification

#= Format Specification rules =#
abstract FormatRequirement

type IncompatibleFormatException <: Exception
    msg::Compat.UTF8String
end

#= Format helpers =#
function allowable(x, y)
    if isempty(x)
        return y
    elseif isempty(y)
        return x
    end
    merged = typeof(x)()
    for k in keys(x)
        if haskey(y, k)
            merged[k] = x[k] + y[k]
        end
    end
    merged
end

function best(x)
    top = maximum(values(x))
    for (k, v) in x
        if v == top
            return k
        end
    end
end

function takenonzero(a, b, zero)
    if a == zero
        b
    elseif b == zero
        a
    elseif a == b
        a
    else throw(IncompatibleFormatException("Can't reconcile $a and $b")) end
end

"""
Return true if two `FormatRequirement`s conflict.
"""
conflict(x, y) = typeof(x) ≡ typeof(y)

"""
Reconcile two conflicting `FormatRequirement`s if possible.
"""
function reconcile end

"""
A collection of `FormatRequirement`s.
"""
immutable FormatSpecification
    reqs::Vector{FormatRequirement}
end

function Base.push!(spec::FormatSpecification, nextreq::FormatRequirement)
    for (i, req) in enumerate(spec.reqs)
        if conflict(nextreq, req)
            # zap the conflicting requirement
            deleteat!(spec.reqs, i)

            # reconcile the two conflicting requirements
            # then add the mutally agreed requirements
            altreqs = reconcile(nextreq, req)
            foldl(push!, spec, altreqs)
            return spec
        end
    end
    # no conflict, return with new requirement
    push!(spec.reqs, nextreq)
    spec
end

function Base.union(x::FormatSpecification, y::FormatSpecification)
    result = FormatSpecification(copy(x.reqs))
    for req in y.reqs
        push!(result, req)
    end
    result
end

function Base.get{T<:FormatRequirement}(spec::FormatSpecification, ::Type{T}, d)
    for req in spec.reqs
        if isa(req, T)
            return req
        end
    end
    d
end

end  # module DeclarativeFormat
