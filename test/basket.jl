# Baskets
@test StaticBasket([100USD, 200USD]) == StaticBasket(300USD)

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

# False positive tests for comparison
@test basket_c ≠ StaticBasket()
@test basket_c ≠ StaticBasket([100USD, 20EUR, 20GBP])
@test StaticBasket([100USD, 20EUR, 20GBP]) ≠ basket_c

# Mixed arithmetic
basket_h = basket_f + 20JPY
basket_i = basket_h - 100USD
basket_j = -20EUR - basket_i
basket_k = DynamicBasket() + basket_j

@test basket_h == StaticBasket([100USD, -20EUR, 20JPY])
@test basket_i == StaticBasket([-20EUR, 20JPY])
@test basket_j == -20JPY
@test basket_j == basket_k

# False positive tests for comparison
@test basket_i ≠ -20EUR
@test basket_j ≠ -20USD
@test basket_i ≠ basket_j

# Basket constructor & zero
basket_l = StaticBasket([basket_i, basket_j, 100JPY])
basket_m = zero(StaticBasket)
basket_n = zero(basket_l)
basket_o = zero(DynamicBasket)
@test basket_l == StaticBasket([-20EUR, 100JPY])
@test basket_m == basket_n == StaticBasket() == basket_o

# Errors
@test_throws ArgumentError StaticBasket([1, 2, 3])
@test_throws ArgumentError DynamicBasket([1USD, (1USD, 2USD, 3)])

# Iteration & access
@test isempty(collect(StaticBasket([100USD, -100USD])))
@test basket_g[:EUR] == -5EUR
@test haskey(StaticBasket([10USD, -10CAD]), :CAD)
@test !haskey(StaticBasket([10USD, -10USD]), :USD)
@test length(collect(StaticBasket([1USD, 2USD]))) == 1
@test length(collect(StaticBasket([1USD, 1CAD]))) == 2

# Dynamic
basket_dyn = DynamicBasket() + basket_g
basket_dyn[:CAD] = 10CAD
@test basket_dyn == DynamicBasket([25USD, -5EUR, 10CAD])
@test haskey(basket_dyn, :USD)
@test !haskey(basket_dyn, :JPY)
push!(basket_dyn, 15JPY)
@test basket_dyn == DynamicBasket([25USD, -5EUR, 10CAD, 15JPY])
push!(basket_dyn, -10EUR)
@test basket_dyn == DynamicBasket([25USD, -15EUR, 10CAD, 15JPY])
push!(basket_dyn, -10CAD)
@test !haskey(basket_dyn, :CAD)  # zero keys should act invisible
@test length(collect(basket_dyn)) == 3
push!(basket_dyn, StaticBasket([25USD, 25EUR]))
@test basket_dyn == StaticBasket([50USD, 10EUR, 15JPY])

# Errors
@test_throws MethodError basket_a * basket_b
@test_throws MethodError basket_a / basket_b
@test_throws MethodError basket_a > basket_b
@test_throws AssertionError basket_dyn[:USD] = 100CAD
