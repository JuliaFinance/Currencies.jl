using Currencies
using Base.Test

# arithmetic
@test 1usd + 2usd == 3usd
@test 1.5usd * 3 == 4.5usd
@test 1.11usd * 999 == 1108.89usd

# no mixing types
@test_throws MethodError 1usd + 1cad
