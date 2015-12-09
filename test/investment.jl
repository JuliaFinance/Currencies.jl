@testset "Future Value" begin
    @test compoundfv(1000USD, 0.02, 12) == 1268.24USD
    @test simplefv(1000USD, 0.04, 12) == 1480USD

    # compoundfv edge cases
    @test compoundfv(1000USD, 0.02, 1.5) == 1030.15USD
    @test compoundfv(1000USD, -0.01, 2) == 980.10USD

    # note π doesn't work directly because Irrational has no one()
    @test compoundfv(1000USD, π-1, 0) == 1000USD

    # generic use cases
    @test compoundfv(1, e-1, 10) ≈ exp(10)
    @test compoundfv(StaticBasket([USD, EUR]), 0.1, 2) ==
        StaticBasket([1.21USD, 1.21EUR])
end
