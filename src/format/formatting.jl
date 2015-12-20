#= Powerful pretty-printing =#
include("rules.jl")
include("decimals.jl")
include("render.jl")
include("templates.jl")

#= Monetary & Basket Display Interface =#
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
    print(io, format(m; styles=[:plain]))
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
    print(io, string('$', format(m; styles=[:latex]), '$'))
end

function Base.writemime(io::IO, ::MIME"text/markdown", b::Basket)
    len = length(b)
    println(io, "\$$len\$-currency `$(typeof(b))`:")
    for val in b
        write(io, "\n - ")
        writemime(io, "text/latex", val)
    end
end
