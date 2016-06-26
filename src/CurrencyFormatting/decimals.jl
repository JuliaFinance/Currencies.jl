#= Digit / Decimal helper functions =#

function digitseparate(amt::Integer, sep::AbstractString, rule::Tuple{Int, Int})
    untilnext = rule[1]
    result = []
    for d in digits(amt)
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
