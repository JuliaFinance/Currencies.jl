## Monetary & Basket Display Functions ##

function curdisplay(num, dec; useunicode=true)
    minus = useunicode ? '−' : '-'
    if dec == 0
        return num < 0 ? "$minus$(abs(num))" : num
    end
    unit = 10 ^ dec
    s, num = sign(num), abs(num)
    full = fld(num, unit)
    part = join(reverse(digits(num % unit, 10, dec)))
    if s < 0
        "$minus$full.$part"
    else
        "$full.$part"
    end
end

function Base.show(io::IO, m::Monetary)
    print(io, int(m) / 10.0^decimals(m))
    print(io, currency(m))
end

function Base.show(io::IO, b::Basket)
    write(io, "$(typeof(b))([")
    write(io, join(b, ","))
    print(io, "])")
end

function Base.writemime(io::IO, ::MIME"text/plain", m::Monetary)
    cur = currency(m)
    print(io, "$(curdisplay(m.amt, decimals(m))) $cur")
end

function Base.writemime(io::IO, ::MIME"text/plain", b::Basket)
    len = length(b)
    write(io, "$len-currency $(typeof(b)):")
    for val in b
        write(io, "\n ")
        writemime(io, "text/plain", val)
    end
end

function Base.writemime(io::IO, ::MIME"text/latex", m::Monetary)
    cur = currency(m)
    num = curdisplay(m.amt, decimals(m); useunicode=false)
    print(io, "\$$num\\,\\mathrm{$cur}\$")
end

function Base.writemime(io::IO, ::MIME"text/markdown", b::Basket)
    len = length(b)
    println(io, "\$$len\$-currency `$(typeof(b))`:")
    for val in b
        write(io, "\n - ")
        writemime(io, "text/latex", val)
    end
end

## Monetary Format Functions ##

type IncompatibleFormatException <: Exception end

function takenonzero(a, b, zero)
    if a == zero
        b
    elseif b == zero
        a
    else throw(IncompatibleFormatException()) end
end

immutable ParenthesizeNegative
    symloc::Symbol  # :inside, :outside, or :unspecified
end
ParenthesizeNegative() = ParenthesizeNegative(:unspecified)

immutable DigitSeparator
    sep::Char              # e.g. ',', '.', '\'', ' '; '\0' for unspecified
    rule::Tuple{Int, Int}  # first, rest, e.g. (3, 3); (0, 0) for unspecified
end
DigitSeparator(c::Char) = DigitSeparator(c, (3, 3))

immutable DecimalSeparator
    sep::Char  # e.g. ',', '.'; '\0' for unspecified
end

immutable CurrencySymbol
    style::Symbol  # :iso4217, :long, :short, or :unspecified
end

reconcile(p::ParenthesizeNegative, p′::ParenthesizeNegative) =
    ParenthesizeNegative(takenonzero(p.symloc, p′.symloc, :unspecified))

function reconcile(d::DigitSeparator, d′::DigitSeparator)
    DigitSeparator(
        takenonzero(d.sep, d′.sep, '\0'),
        takenonzero(d.rule, d′.rule, (0, 0)))
end

reconcile(d::DecimalSeparator, d′::DecimalSeparator) =
    DecimalSeparator(takenonzero(d.sep, d′.sep, '\0'))

const REQUIREMENTS = Dict(
    :finance => [ParenthesizeNegative(:unspecified)],
    :us => [DecimalSeparator('.'), DigitSeparator(',')],
    :european => [DecimalSeparator(','), DigitSeparator('.')])

"""
    format(m::Monetary; styles=[:finance]) → UTF8String

Format the given monetary amount to meet the requirements of the given styles.
Available styles are: `:finance`, `:us`, and `:european`.
"""
function format(c::Monetary; style=[:finance])

end
