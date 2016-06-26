module CurrencyFormatting

using Compat

using ..CurrenciesCompat
using ..CurrenciesBase
using ..CurrencyData
using ..DeclarativeFormatting
import ..DeclarativeFormatting: conflict, reconcile

export format

include("rules.jl")
include("decimals.jl")
include("templates.jl")
include("render.jl")

# FIXME: For compatibility reasons; change for 0.4.0 release
Base.show(io::IO, m::Monetary) =
        show(IOContext(io, :compact => true), "text/plain", m)
Base.show(io::IO, b::Basket) = show(io, "text/plain", b)

function Base.show(io::IO, ::MIME"text/plain", m::Monetary)
    if get(io, :compact, false)
        print(io, m / CurrenciesBase.unit(m), currency(m))
    else
        print(io, format(m; styles=[:plain]))
    end
end

function Base.show(io::IO, ::MIME"text/plain", b::Basket)
    if get(io, :multiline, false)
        len = length(b)
        write(io, "$len-currency $(typeof(b)):")
        for val in b
            write(io, "\n ")
            show(io, "text/plain", val)
        end
    else
        write(io, "$(typeof(b))([")
        write(io, join([sprint(showcompact, c) for c in b], ","))
        print(io, "])")
    end
end

function Base.show(io::IO, ::MIME"text/latex", m::Monetary)
    print(io, string('$', format(m; styles=[:latex]), '$'))
end

function Base.show(io::IO, ::MIME"text/markdown", b::Basket)
    len = length(b)
    println(io, "\$$len\$-currency `$(typeof(b))`:")
    for val in b
        write(io, "\n - ")
        show(io, "text/latex", val)
    end
end

end  # module CurrencyFormatting
