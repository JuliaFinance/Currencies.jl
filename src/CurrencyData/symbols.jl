#= Extra data for long and short symbols =#

# short symbol: may be ambiguous, take the most commonly-found unicode symbol.
# NB: couldn't find a good free source of this data, so it's very incomplete.
# send a pull request to contribute!
const SHORT_SYMBOL = Dict{Symbol, Compat.UTF8String}(
    :AED => "د.إ",
    :AFN => "؋",
    :ALL => "L",
    :AMD => "֏",
    :ANG => "ƒ",
    :AOA => "Kz",
    :ARS => "\$",
    :AUD => "\$",
    :AWG => "Afl.",
    :AZN => "₼",
    :BBD => "\$",
    :BSD => "\$",
    :CAD => "\$",
    :CHF => "Fr.",
    :CNY => "¥",
    :EUR => "€",
    :GBP => "£",
    :JPY => "¥",
    :KPW => "₩",
    :KRW => "₩",
    :MGA => "Ar",
    :MXN => "\$",
    :NOK => "kr",
    :NZD => "\$",
    :USD => "\$")

# long symbol: short where possible without being ambiguous
const LONG_SYMBOL = Dict{Symbol, Compat.UTF8String}(
    :AED => "د.إ",
    :AFN => "؋",
    :ALL => "L",
    :AMD => "֏",
    :ANG => "ƒ",
    :AOA => "Kz",
    :ARS => "AR\$",
    :AUD => "A\$",
    :AWG => "Afl.",
    :AZN => "₼",
    :BBD => "Bds\$",
    :BSD => "B\$",
    :CAD => "C\$",
    :CHF => "Fr.",
    :CNY => "CN¥",
    :EUR => "€",
    :GBP => "GB£",
    :JPY => "JP¥",
    :KPW => "KP₩",
    :KRW => "KR₩",
    :MGA => "Ar",
    :MXN => "MX\$",
    :NZD => "NZ\$",
    :USD => "US\$")
