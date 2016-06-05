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

#= Format Specification rules =#
abstract FormatRequirement

type IncompatibleFormatException <: Exception
    msg::Compat.UTF8String
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

immutable ParenthesizeNegative <: FormatRequirement
    symloc::Symbol  # :inside, :outside, or :unspecified
end
ParenthesizeNegative() = ParenthesizeNegative(:unspecified)

immutable DigitSeparator <: FormatRequirement
    sep::Compat.UTF8String        # e.g. ",", ".", "'", " "; "\0" for unspecified
    rule::Tuple{Int, Int}  # first, rest, e.g. (3, 3); (0, 0) for unspecified
end
DigitSeparator(c::AbstractString) = DigitSeparator(c, (3, 3))

immutable DecimalSeparator <: FormatRequirement
    sep::Compat.UTF8String  # e.g. ",", "."; "\0" for unspecified
end

immutable CurrencySymbol <: FormatRequirement
    symtype::Symbol   # :short, :long, :iso4217, or :unspecified
    location::Symbol  # :before, :after, :none, :dependent, or :unspecified
    spacing::Symbol   # :space, :none, :dependent, or :unspecified
    glued::Symbol     # :require, :disallow, :unspecified
    compose::Vector{Function}  # apply each function in turn to result
end
function CurrencySymbol(;
    symtype=:unspecified, location=:unspecified,
    spacing=:unspecified, glued=:unspecified,
    compose=Function[])

    CurrencySymbol(symtype, location, spacing, glued, compose)
end

immutable RenderAs <: FormatRequirement
    sym::Symbol                            # name of symbol to require
    options::Dict{Compat.UTF8String, Int}  # Allowable symbols => priority
end

reconcile(p::ParenthesizeNegative, p′::ParenthesizeNegative) =
    [ParenthesizeNegative(takenonzero(p.symloc, p′.symloc, :unspecified))]
function reconcile(d::DigitSeparator, d′::DigitSeparator)
    [DigitSeparator(
        takenonzero(d.sep, d′.sep, "\0"),
        takenonzero(d.rule, d′.rule, (0, 0)))]
end
reconcile(d::DecimalSeparator, d′::DecimalSeparator) =
    [DecimalSeparator(takenonzero(d.sep, d′.sep, "\0"))]
reconcile(s::CurrencySymbol, s′::CurrencySymbol) =
    [CurrencySymbol(
        takenonzero(s.symtype, s′.symtype, :unspecified),
        takenonzero(s.location, s′.location, :unspecified),
        takenonzero(s.spacing, s′.spacing, :unspecified),
        takenonzero(s.glued, s′.glued, :unspecified),
        s.compose ∪ s′.compose)]
function reconcile(s::RenderAs, s′::RenderAs)
    @assert s.sym ≡ s′.sym
    allowed = allowable(s.options, s′.options)
    if isempty(allowed)
        throw(IncompatibleFormatException("Cannot agree on symbol: $(s.sym)."))
    end
    [RenderAs(s.sym, allowed)]
end

# require reconciliation if same type
conflict(x, y) = typeof(x) ≡ typeof(y)
conflict(x::RenderAs, y::RenderAs) = x.sym ≡ y.sym

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

function getsymboltable(spec::FormatSpecification)
    default = Dict(
        :minus_sign => "−",
        :zero_dash => "—",
        :thin_space => " ")
    table = Dict{Symbol, Dict{Compat.UTF8String, Int}}()
    for req in spec.reqs
        if isa(req, RenderAs)
            table[req.sym] = req.options
        end
    end
    for (k, v) in table
        default[k] = best(v)
    end
    default
end
