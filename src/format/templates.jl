#= Formatting template compose functions =#
const LATEX_BACKSLASH_ESCAPE = Set("&%\$#_{}")
const LATEX_OTHER_ESCAPE = Dict(
    '~' => "\\textasciitilde",
    '^' => "\\textasciicircum",
    '\\' => "\\textbackslash")
function escapelatex(x)
    result = Char[]
    for char in x
        if char ∈ LATEX_BACKSLASH_ESCAPE
            push!(result, '\\')
            push!(result, char)
        elseif haskey(LATEX_OTHER_ESCAPE, char)
            append!(result, LATEX_OTHER_ESCAPE[char])
        else
            push!(result, char)
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
    :plain => FormatSpecification([]))
