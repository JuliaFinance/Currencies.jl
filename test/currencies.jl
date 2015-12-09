# Custom currencies
@usingcustomcurrency xbt "Bitcoin (100 satoshi unit)" 2

@testset "@usingcustomcurrency" begin
    @test contains(stringmime("text/plain", 10xbt), "xbt")
    @test contains(stringmime("text/plain", 10xbt), "10.00")
    @test 10xbt - 5xbt == 5xbt
    @test StaticBasket([10xbt, 10USD]) - 10USD == 10xbt
end

custom = newcurrency!(:custom, "Custom Currency", 6)

@testset "newcurrency!()" begin
    @test stringmime("text/plain", 20custom) == "20.000000 custom"
    @test string(20custom) == "20.0custom"
    @test 10custom / 10000000 == 0.000001custom
end

# Currency Info
@testset "currencyinfo()" begin
    @test currencyinfo(:USD) == "United States dollar"
    @test currencyinfo(:custom) == "Custom Currency"
    @test currencyinfo(10custom) == "Custom Currency"
    @test currencyinfo(Monetary{:xbt}) == "Bitcoin (100 satoshi unit)"
    @test currencyinfo(Monetary{:BND, BigInt}) == "Brunei dollar"
end

# Currency
@testset "currency()" begin
    @test currency(2GBP) == :GBP
    @test currency(zero(Monetary{:CNY})) == :CNY
    @test currency(10xbt) == :xbt
    @test currency(custom) == :custom
end

# Default precision
@testset "decimals()" begin
    @test decimals(:USD) == 2
    @test decimals(:JPY) == 0
    @test decimals(Monetary{:USD, BigInt}) == 2
    @test decimals(Monetary{:JPY, Int, 4}) == 4
end
