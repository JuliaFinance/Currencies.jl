#= Tests for Basket values =#
@testset "Basket" begin

# Simple arithmetic
basket_a = Basket(100USD)
basket_b = Basket(20EUR)
basket_c = basket_a + basket_b
basket_d = 4 * basket_c
basket_f = basket_a - basket_b
basket_g = basket_f / 4

# Mixed arithmetic
basket_h = basket_f + 20JPY
basket_i = basket_h - 100USD
basket_j = -20EUR - basket_i
basket_k = Basket() + basket_j
basket_l = (Basket(20USD) * 2 - 20CAD - 40USD) / 2 + 10CAD

@testset "Arithmetic" begin
    @test Basket([100USD, 200USD]) == Basket(300USD)
    @test basket_c == Basket([100USD, 20EUR])
    @test basket_d == Basket([400USD, 80EUR])
    @test basket_f == Basket([100USD, -20EUR])
    @test basket_g == Basket([25USD, -5EUR])

    # false positive tests
    @test basket_c ≠ Basket()
    @test basket_c ≠ Basket([100USD, 20EUR, 20GBP])
    @test Basket([100USD, 20EUR, 20GBP]) ≠ basket_c

    @test basket_h == Basket([100USD, -20EUR, 20JPY])
    @test basket_i == Basket([-20EUR, 20JPY])
    @test basket_j == -20JPY
    @test basket_j == basket_k
    @test basket_l == Basket()
    @test basket_l == 0EUR
    @test isempty(basket_l)

    # false positive tests
    @test basket_i ≠ -20EUR
    @test basket_j ≠ -20USD
    @test basket_i ≠ basket_j
    @test basket_l ≠ 1JPY
    @test basket_l ≠ Basket(1JPY)
end

# Basket constructor & zero
basket_m = Basket([basket_i, basket_j, 100JPY])
basket_n = zero(Basket)
basket_o = zero(basket_m)
basket_p = zero(Basket)
basket_q = Basket([basket_o, Basket([10USD, 20USD])])

@testset "Constructors" begin
    @test basket_m == Basket([-20EUR, 100JPY])
    @test basket_n == basket_o == Basket() == basket_p == zero(JPY)
    @test basket_q == 30USD
    @test one(Basket) ≡ 1

    @testset "Basket — Illegal Construction" begin
        @test_throws Exception Basket([1, 2, 3])
        @test_throws Exception Basket([1USD, (1USD, 2USD, 3)])
    end
end

# Iteration & access
@testset "As Collection" begin
    @test isempty(collect(Basket([100USD, -100USD])))
    @test basket_g[:EUR] == -5EUR
    @test haskey(Basket([10USD, -10CAD]), :CAD)
    @test !haskey(Basket([10USD, -10USD]), :USD)
    @test length(collect(Basket([1USD, 2USD]))) == 1
    @test length(collect(Basket([1USD, 1CAD]))) == 2
end

# Dynamic
basket_dyn = Basket() + basket_g

@testset "Dynamic" begin
    basket_dyn[:CAD] = 10CAD
    @test basket_dyn == Basket([25USD, -5EUR, 10CAD])
    @test haskey(basket_dyn, :USD)
    @test !haskey(basket_dyn, :JPY)
    push!(basket_dyn, 15JPY)
    @test basket_dyn == Basket([25USD, -5EUR, 10CAD, 15JPY])
    push!(basket_dyn, -10EUR)
    @test basket_dyn == Basket([25USD, -15EUR, 10CAD, 15JPY])
    push!(basket_dyn, -10CAD)
    @test !haskey(basket_dyn, :CAD)  # zero keys should act invisible
    @test length(collect(basket_dyn)) == 3
    push!(basket_dyn, Basket([25USD, 25EUR]))
    @test basket_dyn == Basket([50USD, 10EUR, 15JPY])
end

# Errors
@testset "Type Safety" begin
    @test_throws MethodError basket_a * basket_b
    @test_throws MethodError basket_a % basket_b
    @test_throws MethodError basket_a ÷ basket_b
    @test_throws MethodError basket_a ÷ 20USD
    @test_throws MethodError basket_a / basket_b
    @test_throws MethodError basket_a > basket_b
    @test_throws ArgumentError basket_dyn[:USD] = 100CAD
end

end  # testset Basket
