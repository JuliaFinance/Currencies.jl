## Extra data for long and short symbols ##

# short symbol: may be ambiguous, take the most commonly-found unicode symbol.
# NB: couldn't find a good free source of this data, so it's very incomplete.
# send a pull request to contribute!
const SHORT_SYMBOL = Dict{Symbol, UTF8String}(
    :AFN => "؋",
    :AUD => "\$",
    :CAD => "\$",
    :EUR => "€",
    :GBP => "£",
    :JPY => "¥",
    :MGA => "Ar",
    :USD => "\$")

# long symbol: short where possible without being ambiguous
const LONG_SYMBOL = Dict{Symbol, UTF8String}(
    :AFN => "؋",
    :AUD => "AU\$",
    :CAD => "CA\$",
    :EUR => "€",
    :GBP => "GB£",
    :JPY => "¥",
    :MGA => "Ar",
    :USD => "US\$")
