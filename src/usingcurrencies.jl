"""
Export each given currency symbol into the current namespace. The individual
unit exported will be a full unit of the currency specified, not the smallest
possible unit. For instance, `@usingcurrencies EUR` will export `EUR`, a
currency unit worth 1€, not a currency unit worth 0.01€.

    @usingcurrencies EUR, GBP, AUD
    7AUD  # 7.00 AUD
"""
macro usingcurrencies(curs)
    if isexpr(curs, Symbol)
        curs = Expr(:tuple, curs)
    end
    @assert isexpr(curs, :tuple)

    quote
        $([:($cur = one(Monetary{$(Expr(:quote, cur))}))
            for cur in curs.args]...)
    end |> esc
end
