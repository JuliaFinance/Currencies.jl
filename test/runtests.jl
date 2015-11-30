using Currencies
using Base.Test

# get currencies
@usingcurrencies USD, CAD, EUR, GBP

# arithmetic
@test 1USD + 2USD == 3USD
@test 1.5USD * 3 == 4.5USD
@test 1.11USD * 999 == 1108.89USD

# no mixing types
@test_throws MethodError 1USD + 1CAD

# comparisons
@test 1EUR < 2EUR
@test sort([0.5EUR, 0.7EUR, 0.3EUR]) == [0.3EUR, 0.5EUR, 0.7EUR]
@test currency(2GBP) == :GBP

# investment
@test compoundfv(1000USD, 0.02, 12) == 1268.24USD
@test simplefv(1000USD, 0.04, 12) == 1480USD

# big int monetary
BI_USD = Monetary{:USD, BigInt}(100)
@test BigInt(2)^100 * BI_USD + 10BI_USD == (BigInt(2)^100 + 10) * BI_USD
