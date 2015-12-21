#= Valuation — Hard-coded Rates =#
@testset "Valuation" begin
    rates_a = ExchangeRateTable(:USD => 1.0, :CAD => 0.75)
    rates_b = ExchangeRateTable(Dict(
        :USD => 1.0,
        :EUR => 1.3,
        :GBP => 1.5))
    rates_c = ExchangeRateTable(Date(2015, 12, 02), Dict(
        :USD => 1.0,
        :EUR => 1.3,
        :GBP => 1.5,
        :CAD => 0.7,
        :JPY => 0.01))
    rates_d = ExchangeRateTable(
        Date(2015, 12, 02),
        :USD => 1.0,
        :CAD => 0.75)

    @test valuate(rates_a, :CAD, 21USD) == 28CAD
    @test valuate(rates_a, :CAD, DynamicBasket([21USD, 10CAD])) == 38CAD
    @test valuate(rates_b, :USD, 10USD) == 10USD
    @test valuate(rates_b, :EUR, 0.13USD) == 0.1EUR
    @test valuate(rates_c, :USD, StaticBasket([USD, EUR, GBP])) == 3.8USD
    @test valuate(rates_c, :EUR, 100CAD) == 53.85EUR
    @test valuate(rates_c, :JPY, 1USD) == 100JPY
    @test valuate(rates_c, :JPY, -1USD) == -100JPY
    @test valuate(rates_c, :USD, StaticBasket([200JPY, EUR])) == 3.3USD
    @test valuate(rates_c, :JPY, 0USD) == 0JPY
    @test valuate(rates_d, :CAD, 3.14CAD) == 3.14CAD
    @test contains(string(rates_d), ":USD=>1.0")
    @test contains(string(rates_d), ":CAD=>0.75")

    @test_throws KeyError valuate(rates_a, :JPY, 100USD)

    # Valuation at custom precision
    @testset "At Custom Precision" begin
        precisecad = Monetary(:CAD, 10000; precision=4)
        @test valuate(rates_d, Monetary{:USD, Int, 4}, CAD) ==
            Monetary(:USD, 7500; precision=4)
        @test valuate(rates_d, Monetary{:USD}, precisecad) == 0.75USD
    end

    # Valuation with custom representation
    @testset "With Custom Representation" begin
        bigcad = Monetary(:CAD, BigInt(100))
        @test valuate(rates_d, Monetary{:USD, BigInt, 4}, CAD) ==
            Monetary(:USD, BigInt(7500); precision=4)
        @test valuate(rates_d, :USD, bigcad) == 0.75USD
    end

    # Valuation to convert similar currencies
    @testset "Convert Similar Currencies" begin
        bigusd = Monetary(:USD; storage=BigInt)
        @test USD ≡ valuate(Dict(:USD => 1.0), :USD, bigusd)
        @test bigusd == valuate(Dict(:USD => 1.0), typeof(bigusd), USD)
    end
end

#= Valuation — ECB data =#
@testset "ECB data" begin
    rates_e = ecbrates()  # most recent
    rates_f = ecbrates(Date(2015, 08, 05))  # fixed date
    rates_g = ecbrates(Date(2015, 08, 05))  # same as rates_f

    # test cache
    @test rates_e ≡ ecbrates()
    @test rates_f ≡ rates_g

    # test recent rates object
    @test rates_e.date + Dates.Day(4) > Date(now())
    @test !isempty(rates_e)
    @test isa(rates_e, ExchangeRateTable)
    @test valuate(rates_e, :USD, 1USD) == 1USD
    @test valuate(rates_e, :EUR, 20EUR) == 20EUR
    @test haskey(rates_e, :JPY)
    @test length(rates_e) > 10

    # test fixed rates object
    @test isa(rates_f, ExchangeRateTable)
    @test rates_f.date == Date(2015, 08, 05)
    @test valuate(rates_f, :AUD, 100USD) == 135.58AUD
end
