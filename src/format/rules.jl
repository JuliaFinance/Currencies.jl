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

# limit for extremely problematic (i.e. impossible) formats
const HARD_LIMIT = 1000

abstract FormatRequirement

type IncompatibleFormatException <: Exception
    msg::UTF8String
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
    sep::UTF8String        # e.g. ",", ".", "'", " "; "\0" for unspecified
    rule::Tuple{Int, Int}  # first, rest, e.g. (3, 3); (0, 0) for unspecified
end
DigitSeparator(c::AbstractString) = DigitSeparator(c, (3, 3))

immutable DecimalSeparator <: FormatRequirement
    sep::UTF8String  # e.g. ",", "."; "\0" for unspecified
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
    sym::Symbol                     # name of symbol to require
    options::Dict{UTF8String, Int}  # Allowable symbols => priority
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

function Base.union(x::FormatSpecification, y::FormatSpecification)
    result = copy(x.reqs)
    add = Queue(FormatRequirement)
    for req in y.reqs
        enqueue!(add, req)
    end

    while !isempty(add)
        if length(add) > HARD_LIMIT
            throw(IncompatibleFormatException(
                "Reconciliation probably won't converge."))
        end

        nextreq = dequeue!(add)

        for i in 1:length(result)
            req = result[i]
            if conflict(nextreq, req)
                # zap the conflicting requirement
                deleteat!(result, i)

                # reconcile the two conflicting requirements
                # then add the mutally agreed requirements later
                altreqs = reconcile(nextreq, req)
                foldl(enqueue!, add, altreqs)

                # skip adding to result
                @goto endofloop
            end
        end

        # no conflicts, add to result
        push!(result, nextreq)
        @label endofloop
    end

    FormatSpecification(result)
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
    table = Dict{Symbol, Dict{UTF8String, Int}}()
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
