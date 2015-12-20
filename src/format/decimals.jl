#= Digit / Decimal helper functions =#

function digitseparate(amt::Integer, sep::AbstractString, rule::Tuple{Int, Int})
    ds = digits(amt)
    untilnext = rule[1]
    result = []
    for d in ds
        if untilnext == 0
            push!(result, sep)
            untilnext = rule[2]
        end
        push!(result, string(d))
        untilnext -= 1
    end
    join(reverse(result))
end

function digitseparate(amt::Integer, dsrule::DigitSeparator)
    digitseparate(amt, dsrule.sep, dsrule.rule)
end

pad(num, decimals) = join(reverse(digits(num, 10, decimals)))
