using Currencies
using Base.Test

# arithmetic
@test 1USD + 2USD == 3USD
@test 1.5USD * 3 == 4.5USD
@test 1.11USD * 999 == 1108.89USD

# no mixing types
@test_throws MethodError 1USD + 1CAD
