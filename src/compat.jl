# Additional compatibility helpers (not / not yet in Compat)

# Mock IOContext (simple but slow and incomplete)
if !isdefined(Base, :IOContext)
    export IOContext
    immutable IOContext <: IO
        io::IO
        kv::Dict{Symbol, Any}
    end

    IOContext(x::IOContext, y::Dict{Symbol, Any}) =
            IOContext(x.io, merge(x.kv, y))
    IOContext(x::IO, ys::Union{Pair, Tuple}...) = IOContext(x, Dict(ys))
    IOContext(x::IO; kw...) = IOContext(x, Dict(kw))

    Base.get(io::IOContext, sym::Symbol, default) = get(io.kv, sym, default)
    Base.get(io::IO, sym::Symbol, default) = default

    Base.write(io::IOContext, b::UInt8) = write(io.io, b)
end

# Provide writemime ⇒ show fallback
if VERSION < v"0.5.0-dev+4356"
    verbose_show(io, m, x) =
            show(IOContext(io, multiline=true, limit=false), m, x)
    Base.show(x::IO, y::AbstractString, z) = show(x, MIME(y), z)
    Base.writemime(x::IO, y, z) = show(x, y, z)

    # Replaces multimedia.jl's version (typing so it's more specific)
    Base.Multimedia.reprmime{K}(m::MIME"text/plain", x::K) =
            sprint(verbose_show, m, x)
end
