# Tests for Monetary values
@testset "Monetary" begin

# Basic arithmetic
@testset "Arithmetic" begin
    @test 1USD + 2USD == 3USD
    @test 1USD + 2USD + 3USD == 6USD
    @test 1.5USD * 3 == 4.5USD
    @test 1USD * 2 + 2USD == 4USD
    @test 2 * 1USD * 3 == 6USD
    @test 1.11USD * 999 == 1108.89USD
    @test -1USD == -(1USD)
    @test +20USD == 20USD
    @test 1USD == majorunit(USD)
    @test 1USD == USD
    @test one(25USD) ≡ 1

    @testset "Division" begin
        @test 10USD / 1USD == 10.0
        @test 10USD ÷ 3USD == 3
        @test 10USD % 3USD == 1USD
        @test -10USD ÷ 3USD == -3
        @test -10USD % 3USD == -1USD
        @test divrem(10USD, 3USD) == (10USD ÷ 3USD, 10USD % 3USD)

        @test mod(10USD, 3USD) == 1USD
        @test fld(10USD, 3USD) == 3
        @test mod(-10USD, 3USD) == 2USD
        @test fld(-10USD, 3USD) == -4
        @test fldmod(-10USD, 3USD) == (-4, 2USD)

        if VERSION ≥ v"0.5-"
            @test mod1(10USD, 3USD) == 1USD
            @test fld1(10USD, 3USD) == 4
            @test mod1(-10USD, 3USD) == 2USD
            @test fld1(-10USD, 3USD) == -3
            @test mod1(9USD, 3USD) == 3USD
            @test fld1(9USD, 3USD) == 3
            @test fldmod1(9USD, 3USD) == (3, 3USD)
        end
    end

    @testset "Number-like" begin
        @test abs(-10USD) == 10USD
        @test abs(0USD) == 0USD
        @test abs(10USD) == 10USD
        @test sign(-10USD) == -1
        @test sign(0USD) == 0
        @test sign(10USD) == 1
    end
end

# Type safety
@testset "Type Safety" begin
    @test_throws MethodError 1USD + 1CAD
    @test_throws MethodError 100JPY - 0USD  # even when zero!
    @test_throws MethodError 5USD * 10CAD
    @test_throws MethodError 5USD * 10USD
    @test_throws MethodError 1USD + 1
    @test_throws MethodError 2 - 1JPY
    @test_throws MethodError 1USD / 1CAD
    @test_throws MethodError 10USD ÷ 5        # meaningless
    @test_throws MethodError 10USD % 5        # meaningless
end

@testset "Comparison" begin
    # Comparisons
    @testset "Monetary — Homogenous Comparisons" begin
        @test 1EUR < 2EUR
        @test 3JPY > 2JPY
        @test 3JPY ≥ 3JPY
        @test 9USD ≤ 9.01USD
        @test -1USD ≠ 0USD
        @test sort([0.5EUR, 0.7EUR, 0.3EUR]) == [0.3EUR, 0.5EUR, 0.7EUR]

        # immutable types should be **equivalent**
        @test 10USD ≡ 10USD
        @test zero(USD) ≡ 0USD
        @test -majorunit(USD) ≡ +(-USD)
    end

    # Type safety for comparisons
    @testset "Monetary — Heterogenous Comparisons" begin
        @test 1EUR ≠ 1USD
        @test 5USD ≠ 5
        @test 5USD ≠ 500

        @test_throws MethodError EUR > USD
        @test_throws MethodError GBP ≥ USD
        @test_throws MethodError JPY < USD
    end
end

# Big int monetary
BI_USD = Monetary(:USD, BigInt(100))
BI_USD2 = majorunit(Monetary{:USD, BigInt})
BI_USD3 = Monetary(:USD; storage=BigInt)
I128_USD = majorunit(Monetary{:USD, Int128})
@testset "Custom Representation" begin
    @test BigInt(2)^100 * BI_USD + 10BI_USD == (BigInt(2)^100 + 10) * BI_USD

    # test **equality** — note equivalence is untrue because BigInt
    @test BI_USD == BI_USD2 == BI_USD3

    # wrapping behaviour (strange but documented)
    @test typemin(Int128) * I128_USD ≡ typemax(Int128) * I128_USD + I128_USD

    # mixing allowed
    @test BI_USD + USD == 2USD
    @test typeof(BI_USD + USD) == typeof(BI_USD)
    @test typeof(I128_USD + USD) == typeof(I128_USD)
    @test BI_USD - I128_USD == 0USD
    @test typeof(BI_USD - I128_USD) == typeof(BI_USD)
    @test BI_USD / I128_USD == 1.0
    @test typeof(BI_USD / I128_USD) == BigFloat
end

# Custom decimals
@testset "Custom Precision" begin
    flatusd = majorunit(Monetary{:USD, Int, 0})
    millusd = majorunit(Monetary{:USD, Int, 3})

    # Constructor equivalence
    @test flatusd ≡ Monetary(:USD, 1; precision=0)
    @test flatusd ≡ Monetary(:USD; precision=0)
    @test millusd ≡ Monetary(:USD, 1000; precision=3)
    @test millusd ≡ Monetary(:USD; precision=3, storage=Int)
    @test flatusd ≢ millusd

    # Custom precision arithmetic
    @test 1.111millusd + 1.222millusd == 2.333millusd
    @test 0.1flatusd == 0flatusd
    @test 0.001millusd ≠ 0.002millusd

    # Mixing comparisons allowed (surprising behaviour?)
    @test zero(flatusd) ≢ 0USD
    @test flatusd ≥ USD

    # and arithmetic also, but promotes to BigInt (surprising behaviour?)
    @test flatusd + millusd == 2USD
    @test typeof(flatusd + millusd) == Monetary{:USD, BigInt, 3}
    @test flatusd / millusd == 1.0
    @test typeof(flatusd / millusd) == BigFloat

    # Special metals — precision required
    @test_throws ArgumentError @usingcurrencies XAU
    @test_throws ArgumentError Monetary(:XAU)
    @test_throws ArgumentError Monetary(:XAU, 100)

    @test Monetary(:XAU; precision=2) ≡ majorunit(Monetary{:XAU,Int,2})
    @test Monetary(:XSU; precision=0).val == 1
end

@testset "Constructors" begin
    # the grand constructor test!
    # split up for easy debugging
    @test USD ≡ majorunit(Monetary{:USD})
    @test USD ≡ majorunit(Monetary{:USD, Int, 2})
    @test USD ≡ Monetary(:USD)
    @test USD ≡ Monetary(:USD; storage=Int)
    @test USD ≡ Monetary(:USD; precision=2)
    @test USD ≡ Monetary(:USD; storage=Int, precision=2)
    @test USD ≡ Monetary(:USD, 100)
    @test USD ≡ Monetary(:USD, 100; precision=2)

    @test USD ≢ Monetary(:USD, 1)
    @test USD ≢ Monetary(:USD; precision=0)
    @test USD ≢ Monetary(:USD; precision=4)
    @test USD ≢ Monetary(:USD; storage=BigInt)

    # and the zero test
    @test 0USD ≡ zero(Monetary{:USD})
    @test 0USD ≡ zero(Monetary{:USD,Int,2})
    @test 0USD ≡ Monetary(:USD, 0)
    @test 0USD ≡ Monetary(:USD, 0; precision=2)

    @test 0USD ≢ USD
    @test 0USD ≢ Monetary(:USD, 0; precision=0)
    @test 0USD ≢ Monetary(:USD, BigInt(0))
end

end  # testset Monetary
