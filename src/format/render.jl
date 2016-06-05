#= Rendering Monetary values =#

# render functions
function loweramount(spec::FormatSpecification, m::Monetary)
    negfs = get(spec, ParenthesizeNegative, nothing)
    if sign(m) < 0
        if negfs == nothing
            [:symbefore, :minus_sign, :amount, :symafter]
        elseif negfs.symloc == :inside
            ["(", :symbefore, :amount, :symafter, ")"]
        else
            [:symbefore, "(", :amount, ")", :symafter]
        end
    elseif sign(m) == 0 && negfs != nothing
        [:symbefore, :zero_dash, :symafter]
    else
        [:symbefore, :amount, :symafter]
    end
end

function resolve_symbol(symtype::Symbol, m::Monetary)
    if symtype == :short
        shortsymbol(m)
    elseif symtype == :long
        longsymbol(m)
    else
        iso4217alpha(m)
    end
end

"""
Compile the symbol requirement to a simplified form.

In the simplified form, the `location` field is guaranteed to take the value of
`:before` or `:after`.
"""
function compile(symreq::CurrencySymbol, m::Monetary)
    loc = if symreq.location == :dependent
        get(LOCAL_SYMBOL_LOCATION, currency(m), :after)
    elseif symreq.location == :before
        :before
    else  # :unspecified or :after
        :after
    end
    CurrencySymbol(
        symreq.symtype,
        loc,
        symreq.spacing,
        symreq.glued,
        symreq.compose)
end

function symbolize(template::Vector, spec::FormatSpecification, m::Monetary)
    symreq = compile(get(spec, CurrencySymbol, CurrencySymbol()), m)
    desired_symbol = foldl(
        |>, resolve_symbol(symreq.symtype, m), symreq.compose)
    spacing = symreq.spacing == :none ? "" : :thin_space

    next_template = []
    for item in template
        if item == :symbefore
            if symreq.location == :before && symreq.glued != :require
                push!(next_template, desired_symbol, spacing)
            end
        elseif item == :symafter
            if symreq.location ∈ (:after, :dependent, :unspecified) &&
                symreq.glued != :require
                push!(next_template, spacing, desired_symbol)
            end
        elseif item == :amount && symreq.glued == :require
            if symreq.location == :before
                push!(next_template, desired_symbol, spacing, item)
            elseif symreq.location == :after
                push!(next_template, item, spacing, desired_symbol)
            end
        else
            push!(next_template, item)
        end
    end
    next_template
end

function render(template::Vector, spec::FormatSpecification, m::Monetary)
    decisep = get(spec, DecimalSeparator, DecimalSeparator("."))
    digisep = get(spec, DigitSeparator, DigitSeparator(""))

    prec = decimals(m)
    intpart = abs(m.val) ÷ 10^prec
    floatpart = abs(m.val) % 10^prec

    syms = getsymboltable(spec)
    next_template = []
    for item in template
        if item == :amount
            push!(next_template, digitseparate(intpart, digisep))
            if prec != 0
                push!(next_template, decisep.sep, lpad(floatpart, prec, '0'))
            end
        elseif haskey(syms, item)
            push!(next_template, syms[item])
        else push!(next_template, item) end
    end
    next_template
end


"""
    format(m::Monetary; styles=[:finance])

Format the given monetary amount to meet the requirements of the given style.
Available styles are: `:finance`, `:us`, `:european`, and `:brief`. For LaTeX
output, provide `:latex`. For plain output (default), provide `:plain`.
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
    join(template) |> Compat.UTF8String
end
