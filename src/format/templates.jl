#= Formatting template compose functions =#
const LATEX_BACKSLASH_ESCAPE = Set("&%\$#_{}")
const LATEX_OTHER_ESCAPE = Dict(
    '~' => "{\\textasciitilde}",
    '^' => "{\\textasciicircum}",
    '\\' => "{\\textbackslash}")
function escapelatex(text)
    result = Char[]
    for c in text
        if c ∈ LATEX_BACKSLASH_ESCAPE
            push!(result, '\\')
            push!(result, c)
        elseif haskey(LATEX_OTHER_ESCAPE, c)
            append!(result, LATEX_OTHER_ESCAPE[c])
        else
            push!(result, c)
        end
    end
    UTF8String(result)
end

romanfont(s) = string("\\mathrm{", s, "}")

#= Available formatting templates =#
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
        CurrencySymbol(symtype=:short, spacing=:none, glued=:require)]),
    :latex => FormatSpecification([
        CurrencySymbol(compose=[escapelatex, romanfont]),
        RenderAs(:minus_sign, Dict("-" => 0)),
        RenderAs(:zero_dash, Dict("\\textrm{---}" => 0)),
        RenderAs(:thin_space, Dict("\\," => 0))]),
    :plain => FormatSpecification([]),
    :local => FormatSpecification([
        CurrencySymbol(location=:dependent)]))
