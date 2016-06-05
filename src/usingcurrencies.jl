"""
Export each given currency symbol into the current namespace. The individual
unit exported will be a full unit of the currency specified, not the smallest
possible unit. For instance, `@usingcurrencies EUR` will export `EUR`, a
currency unit worth 1€, not a currency unit worth 0.01€.

    @usingcurrencies EUR, GBP, AUD
    7AUD  # 7.00 AUD

There is no sane unit for certain currencies like `XAU` or `XAG`, so this macro
does not work for those. Instead, define them manually:

    const XAU = Monetary(:XAU; precision=4)
"""
macro usingcurrencies(curs)
    if isa(curs, Symbol)
        curs = Expr(:tuple, curs)
    end
    @assert Meta.isexpr(curs, :tuple)

    quote
        $([:(const $cur = Monetary($(Expr(:quote, cur))))
            for cur in curs.args]...)
        nothing
    end |> esc
end
