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
conflict(x::RenderAs, y::RenderAs) = x.sym ≡ y.sym

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
