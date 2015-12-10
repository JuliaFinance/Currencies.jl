# Display methods (show & print & writemime) tests

@testset "text/plain" begin
    @test contains(stringmime("text/plain", 1USD), "1.00")
    @test contains(stringmime("text/plain", 1JPY), "1")
    @test contains(stringmime("text/plain", StaticBasket([1USD, 1CAD])), "CAD")
    @test contains(stringmime("text/plain", DynamicBasket([1USD, 1CAD])), "USD")
    @test contains(
        stringmime("text/plain", StaticBasket([100USD, 200EUR])),
        "200.00 EUR")
    @test !contains(
        stringmime("text/plain", StaticBasket([1USD, 1CAD, -1CAD])), "CAD")
    @test stringmime("text/plain", +USD) == "1.00 USD"
    @test stringmime("text/plain", -USD) == "−1.00 USD"

    @test stringmime("text/plain", one(Monetary{:USD, BigInt, 5})) ==
        "1.00000 USD"
    @test stringmime("text/plain", -one(Monetary{:JPY, Int, 2})) ==
        "−1.00 JPY"
    @test stringmime("text/plain", 7.2512Monetary(:XAU; precision=4)) ==
        "7.2512 XAU"
end

@testset "text/latex" begin
    @test stringmime("text/latex", 100USD) == "\$100.00\\,\\mathrm{USD}\$"
    @test stringmime("text/latex", -100JPY) == "\$-100\\,\\mathrm{JPY}\$"
    @test stringmime("text/latex", 0GBP) == "\$0.00\\,\\mathrm{GBP}\$"
    @test stringmime("text/latex", zero(Monetary{:EUR, Int, 0})) ==
        "\$0\\,\\mathrm{EUR}\$"
end

@testset "text/markdown" begin
    basketstr = stringmime(
        "text/markdown", DynamicBasket([USD, 20CAD, -10JPY]))

    @test contains(basketstr, "`Currencies.DynamicBasket`")
    @test contains(basketstr, "\$3\$-currency")
    @test contains(basketstr, " - \$-10\\,\\mathrm{JPY}\$")
end

@testset "print & show" begin
    @test string(USD) == "1.0USD"
    @test string(0.01USD) == "0.01USD"
    @test string(20JPY) == "20.0JPY"

    # this test is a bit complicated because order is undefined
    basketstr = string(StaticBasket([USD, 20CAD, -10JPY]))
    @test contains(basketstr, "StaticBasket([")
    @test contains(basketstr, "-10.0JPY")
    @test contains(basketstr, "20.0CAD")

    # test compatibility between show & print
    @test sprint(show, 0.02USD) == string(0.02USD)
end
