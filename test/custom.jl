#= Custom currencies =#

@testset "Custom" begin

@usingcustomcurrency xbt "Bitcoin (100 satoshi unit)" 2
custom = newcurrency!(:custom, "Custom Currency", 6)

@testset "@usingcustomcurrency" begin
    @test contains(stringmime("text/plain", 10xbt), "xbt")
    @test contains(stringmime("text/plain", 10xbt), "10.00")
    @test 10xbt - 5xbt == 5xbt
    @test format(-1111.11xbt, styles=[:us, :finance]) == "xbt (1,111.11)"
    @test Basket([10xbt, 10USD]) - 10USD == 10xbt

    @test currencyinfo(Monetary{:xbt}) == "Bitcoin (100 satoshi unit)"

    @test iso4217alpha(Monetary{:xbt}) == "xbt"
    @test iso4217alpha(100xbt) == "xbt"

    @test currency(10xbt) == :xbt
end

@testset "newcurrency!()" begin
    @test stringmime("text/plain", 20custom) == "20.000000 custom"
    @test string(20custom) == "20.0custom"
    @test format(-20custom) == "(20.000000) custom"
    @test 10custom / 10000000 == 0.000001custom

    @test currencyinfo(:custom) == "Custom Currency"
    @test currencyinfo(10custom) == "Custom Currency"

    @test iso4217num(:custom) == 0
    @test iso4217num(10custom) == 0

    @test currency(custom) == :custom
end

end  # testset Custom
