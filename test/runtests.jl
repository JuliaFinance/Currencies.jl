using Currencies
using Base.Test

# get currencies
@usingcurrencies USD, CAD, EUR, GBP, JPY

# arithmetic
@test 1USD + 2USD == 3USD
@test 1.5USD * 3 == 4.5USD
@test 1.11USD * 999 == 1108.89USD
@test -1USD == -(1USD)

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

# baskets
@test StaticBasket([100USD, 200USD]) == StaticBasket(300USD)
@test contains(string(StaticBasket([100USD, 200EUR])), "200.00 EUR")

basket_a = StaticBasket(100USD)
basket_b = StaticBasket(20EUR)
basket_c = basket_a + basket_b
basket_d = 4 * basket_c
basket_e = compoundfv(basket_c, 0.02, 12)
basket_f = basket_a - basket_b
basket_g = basket_f / 4
@test basket_c == StaticBasket([100USD, 20EUR])
@test basket_d == StaticBasket([400USD, 80EUR])
@test basket_e == StaticBasket([126.82USD, 25.36EUR])
@test basket_f == StaticBasket([100USD, -20EUR])
@test basket_g == StaticBasket([25USD, -5EUR])

# iteration, access, & dynamic
@test isempty(collect(StaticBasket([100USD, -100USD])))
@test basket_g[:EUR] == -5EUR
basket_dyn = DynamicBasket() + basket_g
basket_dyn[:CAD] = 10CAD
@test basket_dyn == DynamicBasket([25USD, -5EUR, 10CAD])
push!(basket_dyn, 15JPY)
@test basket_dyn == DynamicBasket([25USD, -5EUR, 10CAD, 15JPY])
push!(basket_dyn, -10EUR)
@test basket_dyn == DynamicBasket([25USD, -15EUR, 10CAD, 15JPY])

@test_throws AssertionError basket_dyn[:USD] = 100CAD
