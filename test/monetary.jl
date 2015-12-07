# Tests for Monetary values

# Basic arithmetic
@testset "Monetary arithmetic" begin
    @test 1USD + 2USD == 3USD
    @test 1USD + 2USD + 3USD == 6USD
    @test 1.5USD * 3 == 4.5USD
    @test 1USD * 2 + 2USD == 4USD
    @test 2 * 1USD * 3 == 6USD
    @test 1.11USD * 999 == 1108.89USD
    @test -1USD == -(1USD)
    @test 1USD == one(USD)
    @test 10USD / 1USD == 10.0
    @test 10USD ÷ 3USD == 3
    @test 10USD % 3USD == 1USD
    @test one(Monetary{:USD}) == USD
    @test zero(Monetary{:USD}) == 0USD
end

# Type safety
@testset "Monetary type safety" begin
    @test_throws ArgumentError 1USD + 1CAD
    @test_throws ArgumentError 100JPY - 0USD  # even when zero!
    @test_throws MethodError 5USD * 10CAD
    @test_throws MethodError 5USD * 10USD
    @test_throws MethodError 1USD + 1
    @test_throws MethodError 2 - 1JPY
    @test_throws MethodError 1USD / 1CAD
    @test_throws MethodError 10USD ÷ 5        # meaningless
    @test_throws MethodError 10USD % 5        # meaningless
end

# Comparisons
@testset "Monetary comparisons (same type)" begin
    @test 1EUR < 2EUR
    @test 3JPY > 2JPY
    @test 3JPY ≥ 3JPY
    @test 9USD ≤ 9.01USD
    @test -1USD ≠ 0USD
    @test sort([0.5EUR, 0.7EUR, 0.3EUR]) == [0.3EUR, 0.5EUR, 0.7EUR]
end

# Type safety
@testset "Monetary comparisons (different type)" begin
    @test 1EUR ≠ 1USD
    @test 5USD ≠ 5
    @test 5USD ≠ 500

    @test_throws MethodError EUR > USD
    @test_throws MethodError GBP ≥ USD
    @test_throws MethodError JPY < USD
end

# Big int monetary
BI_USD = Monetary(:USD, BigInt(100))
@testset "BigInt Monetary" begin
    @test BigInt(2)^100 * BI_USD + 10BI_USD == (BigInt(2)^100 + 10) * BI_USD
    @test_throws ArgumentError BI_USD + USD
end

# Custom decimals
@testset "Custom precision" begin
    flatusd = one(Monetary{:USD, Int, 0})
    millusd = one(Monetary{:USD, Int, 3})

    # Constructor equivalence
    @test flatusd == Monetary(:USD, 1; precision=0)
    @test millusd == Monetary(:USD, 1000; precision=3)
    @test flatusd ≠ millusd

    # Custom precision arithmetic
    @test 1.111millusd + 1.222millusd == 2.333millusd
    @test 0.1flatusd == 0flatusd
    @test 0.001millusd ≠ 0.002millusd

    # Absolutely no mixing (surprising behaviour?)
    @test zero(flatusd) ≠ 0USD
    @test_throws MethodError flatusd ≥ USD
    @test_throws ArgumentError flatusd + millusd
    @test_throws MethodError flatusd / millusd
end
