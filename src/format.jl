## Monetary Format Functions ##

# limit for extremely problematic (i.e. impossible) formats
const HARD_LIMIT = 1000

abstract FormatRequirement

immutable FormatSpecification
    reqs::Vector{FormatRequirement}
end

# helper functions
function digitseparate(amt::Integer, sep::AbstractString, rule::Tuple{Int, Int})
    ds = digits(amt)
    untilnext = rule[1]
    result = []
    for d in ds
        if untilnext == 0
            push!(result, sep)
            untilnext = rule[2]
        end
        push!(result, string(d))
        untilnext -= 1
    end
    join(reverse(result))
end

# render functions
function loweramount(spec::FormatSpecification, m::Monetary)
    negfs = nothing
    for req in spec.reqs
        if isa(req, ParenthesizeNegative)
            negfs = req
            break
        end
    end
    if m < zero(m)
        if negfs == nothing
            [:symbefore, "−", :amount, :symafter]
        elseif negfs.symloc == :inside
            ["(", :symbefore, :amount, :symafter, ")"]
        else
            [:symbefore, "(", :amount, ")", :symafter]
        end
    elseif m == zero(m) && negfs != nothing
        [:symbefore, "—", :symafter]
    else
        [:symbefore, :amount, :symafter]
    end
end

function symbolize(template::Vector, spec::FormatSpecification, m::Monetary)
    require = CurrencySymbol()
    for req in spec.reqs
        if isa(req, CurrencySymbol)
            require = req
            break
        end
    end
    next = []
    desired_symbol = if require.symtype == :short
        shortsymbol(m)
    elseif require.symtype == :long
        longsymbol(m)
    else
        iso4217alpha(m)
    end
    spacing = if require.spacing == :none
        ""
    else
        " "
    end
    for item in template
        if item == :symbefore
            if require.location == :before && require.glued != :require
                push!(next, desired_symbol)
                push!(next, spacing)
            end
        elseif item == :symafter
            if require.location ∈ (:after, :dependent, :unspecified) &&
                require.glued != :require
                push!(next, spacing)
                push!(next, desired_symbol)
            end
        elseif item == :amount && require.glued == :require
            if require.location == :before
                push!(next, desired_symbol)
                push!(next, spacing)
                push!(next, item)
            elseif require.location ∈ (:after, :dependent, :unspecified)
                push!(next, item)
                push!(next, spacing)
                push!(next, desired_symbol)
            end
        else
            push!(next, item)
        end
    end
    next
end

function render(template::Vector, spec::FormatSpecification, m::Monetary)
    decisep = DecimalSeparator(".")
    digisep = DigitSeparator("")
    for req in spec.reqs
        if isa(req, DigitSeparator)
            digisep = req
        elseif isa(req, DecimalSeparator)
            decisep = req
        end
    end
    dec = decimals(m)
    intpart = abs(int(m)) ÷ 10^dec
    floatpart = abs(int(m)) % 10^dec

    next = []
    for item in template
        if item == :amount
            push!(next, digitseparate(intpart, digisep.sep, digisep.rule))
            if dec != 0
                push!(next, decisep.sep)
                push!(next, pad(floatpart, dec))
            end
        else push!(next, item) end
    end
    next
end

type IncompatibleFormatException <: Exception
    msg::UTF8String
end

function takenonzero(a, b, zero)
    if a == zero
        b
    elseif b == zero
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
end
function CurrencySymbol(;
    symtype=:unspecified, location=:unspecified,
    spacing=:unspecified, glued=:unspecified)

    CurrencySymbol(symtype, location, spacing, glued)
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
        takenonzero(s.glued, s′.glued, :unspecified))]

# require reconciliation if same type
conflict(x, y) = typeof(x) ≡ typeof(y)

function Base.union(x::FormatSpecification, y::FormatSpecification)
    base = copy(x.reqs)
    add = Queue(FormatRequirement)
    for req in y.reqs
        enqueue!(add, req)
    end

    while !isempty(add)
        if length(add) > HARD_LIMIT
            throw(IncompatibleFormatException(
                "Reconciliation probably won't converge."))
        end

        next = dequeue!(add)

        for i in 1:length(base)
            req = base[i]
            if conflict(next, req)
                # zap the conflicting requirement
                deleteat!(base, i)

                # reconcile the two conflicting requirements
                # then add the mutally agreed requirements later
                altreqs = reconcile(next, req)
                foldl(enqueue!, add, altreqs)

                # skip adding to base
                @goto endofloop
            end
        end

        # no conflicts, add to base
        push!(base, next)
        @label endofloop
    end

    FormatSpecification(base)
end

const REQUIREMENTS = Dict(
    :finance => FormatSpecification([
        ParenthesizeNegative()]),
    :us => FormatSpecification([
        DigitSeparator(","),
        DecimalSeparator("."),
        CurrencySymbol(location=:before)]),
    :european => FormatSpecification([
        DigitSeparator("."),
        DecimalSeparator(","),
        CurrencySymbol(location=:after)]),
    :brief => FormatSpecification([
        CurrencySymbol(symtype=:short, spacing=:none, glued=:require)]))

"""
    format(m::Monetary; styles=[:finance])

Format the given monetary amount to meet the requirements of the given style.
Available styles are: `:finance`, `:us`, `:european`, and `:brief`.
"""
function format(m::Monetary; styles=[:finance])
    specs = map(x -> REQUIREMENTS[x], styles)
    reqs = reduce(∪, specs)
    format(m, reqs)
end

function format(m::Monetary, spec::FormatSpecification)
    template = loweramount(spec, m)
    template = symbolize(template, spec, m)
    template = render(template, spec, m)
    join(template) |> UTF8String
end
