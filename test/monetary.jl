# Tests for Monetary values

# Basic arithmetic
@test 1USD + 2USD == 3USD
@test 1USD + 2USD + 3USD == 6USD
@test 1.5USD * 3 == 4.5USD
@test 1USD * 2 + 2USD == 4USD
@test 2 * 1USD * 3 == 6USD
@test 1.11USD * 999 == 1108.89USD
@test -1USD == -(1USD)
@test 1USD == one(USD)
@test 10USD / 1USD == 10.0
@test div(10USD, 3USD) == 3
@test rem(10USD, 3USD) == 1USD
@test one(Monetary{:USD}) == USD

# Type safety
@test_throws ArgumentError 1USD + 1CAD
@test_throws ArgumentError 100JPY - 0USD  # even when zero!
@test_throws MethodError 5USD * 10CAD
@test_throws MethodError 5USD * 10USD
@test_throws MethodError 1USD + 1
@test_throws MethodError 2 - 1JPY
@test_throws MethodError 1USD / 1CAD
@test_throws MethodError div(10USD, 5)    # meaningless
@test_throws MethodError 10USD % 5        # meaningless

# Comparisons
@test 1EUR < 2EUR
@test 3JPY > 2JPY
@test 3JPY >= 3JPY
@test -1USD ≠ 0USD
@test sort([0.5EUR, 0.7EUR, 0.3EUR]) == [0.3EUR, 0.5EUR, 0.7EUR]

# Type safety
@test 1EUR ≠ 1USD
@test 5USD ≠ 5
@test 5USD ≠ 500

@test_throws MethodError EUR > USD
@test_throws MethodError GBP >= USD
@test_throws MethodError JPY < USD

# Big int monetary
BI_USD = Monetary{:USD, BigInt}(100)
@test BigInt(2)^100 * BI_USD + 10BI_USD == (BigInt(2)^100 + 10) * BI_USD
