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
