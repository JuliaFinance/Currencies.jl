# Display methods (show & print & writemime) tests

@testset "Display as text/plain" begin
    @test contains(sprint(writemime, "text/plain", 1USD), "1.00")
    @test contains(sprint(writemime, "text/plain", 1JPY), "1")
    @test contains(
        sprint(writemime, "text/plain", StaticBasket([1USD, 1CAD])), "CAD")
    @test contains(
        sprint(writemime, "text/plain", DynamicBasket([1USD, 1CAD])), "USD")
    @test contains(
        sprint(writemime, "text/plain", StaticBasket([100USD, 200EUR])),
        "200.00 EUR")
    @test !contains(
        sprint(writemime, "text/plain", StaticBasket([1USD, 1CAD, -1CAD])), "CAD")
    @test sprint(writemime, "text/plain", 1USD) == "1.00 USD"
    @test sprint(writemime, "text/plain", -1USD) == "−1.00 USD"
end

@testset "string() [print], show()" begin
    @test string(1USD) == "1.0USD"
    @test string(0.01USD) == "0.01USD"
    @test string(20JPY) == "20.0JPY"

    # this test is a bit complicated because order is undefined
    basketstr = string(StaticBasket([1USD, 20CAD, -10JPY]))
    @test contains(basketstr, "StaticBasket([")
    @test contains(basketstr, "-10.0JPY")
    @test contains(basketstr, "20.0CAD")

    # test compatibility between show & print
    @test sprint(show, 0.02USD) == string(0.02USD)
end
