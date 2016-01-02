#= Tests for Basket values =#
@testset "Basket" begin

# Simple arithmetic
basket_a = StaticBasket(100USD)
basket_b = StaticBasket(20EUR)
basket_c = basket_a + basket_b
basket_d = 4 * basket_c
basket_e = compoundfv(basket_c, 0.02, 12)
basket_f = basket_a - basket_b
basket_g = basket_f / 4

# Mixed arithmetic
basket_h = basket_f + 20JPY
basket_i = basket_h - 100USD
basket_j = -20EUR - basket_i
basket_k = DynamicBasket() + basket_j
basket_l = (DynamicBasket(20USD) * 2 - 20CAD - 40USD) / 2 + 10CAD

@testset "Arithmetic" begin
    @test StaticBasket([100USD, 200USD]) == StaticBasket(300USD)
    @test basket_c == StaticBasket([100USD, 20EUR])
    @test basket_d == StaticBasket([400USD, 80EUR])
    @test basket_e == StaticBasket([126.82USD, 25.36EUR])
    @test basket_f == StaticBasket([100USD, -20EUR])
    @test basket_g == StaticBasket([25USD, -5EUR])

    # false positive tests
    @test basket_c ≠ StaticBasket()
    @test basket_c ≠ StaticBasket([100USD, 20EUR, 20GBP])
    @test StaticBasket([100USD, 20EUR, 20GBP]) ≠ basket_c

    @test basket_h == StaticBasket([100USD, -20EUR, 20JPY])
    @test basket_i == StaticBasket([-20EUR, 20JPY])
    @test basket_j == -20JPY
    @test basket_j == basket_k
    @test basket_l == StaticBasket()
    @test basket_l == 0EUR
    @test isempty(basket_l)

    # false positive tests
    @test basket_i ≠ -20EUR
    @test basket_j ≠ -20USD
    @test basket_i ≠ basket_j
    @test basket_l ≠ 1JPY
    @test basket_l ≠ StaticBasket(1JPY)
end

# Basket constructor & zero
basket_m = StaticBasket([basket_i, basket_j, 100JPY])
basket_n = zero(StaticBasket)
basket_o = zero(basket_m)
basket_p = zero(DynamicBasket)
basket_q = DynamicBasket([basket_o, StaticBasket([10USD, 20USD])])

@testset "Constructors" begin
    @test basket_m == StaticBasket([-20EUR, 100JPY])
    @test basket_n == basket_o == StaticBasket() == basket_p == zero(JPY)
    @test basket_q == 30USD

    @testset "Basket — Illegal Construction" begin
        @test_throws Exception StaticBasket([1, 2, 3])
        @test_throws Exception DynamicBasket([1USD, (1USD, 2USD, 3)])
        @test_throws MethodError one(StaticBasket)
    end
end

# Iteration & access
@testset "As Collection" begin
    @test isempty(collect(StaticBasket([100USD, -100USD])))
    @test basket_g[:EUR] == -5EUR
    @test haskey(StaticBasket([10USD, -10CAD]), :CAD)
    @test !haskey(StaticBasket([10USD, -10USD]), :USD)
    @test length(collect(StaticBasket([1USD, 2USD]))) == 1
    @test length(collect(StaticBasket([1USD, 1CAD]))) == 2
end

# Dynamic
basket_dyn = DynamicBasket() + basket_g

@testset "Dynamic" begin
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
end

# Errors
@testset "Type Safety" begin
    @test_throws MethodError basket_a * basket_b
    @test_throws MethodError basket_a % basket_b
    @test_throws MethodError basket_a ÷ basket_b
    @test_throws MethodError basket_a ÷ 20USD
    @test_throws MethodError basket_a / basket_b
    @test_throws MethodError basket_a > basket_b
    @test_throws AssertionError basket_dyn[:USD] = 100CAD
end

end  # testset Basket
