@testset "Data Access" begin

# ISO 4217
@testset "ISO 4217" begin
    @testset "Currency Name" begin
        @test currencyinfo(:USD) == "US Dollar"
        @test currencyinfo(20EUR) == "Euro"
        @test currencyinfo(Monetary{:BND, BigInt}) == "Brunei Dollar"
    end

    @testset "Numeric Code" begin
        @test iso4217num(:BZD) == 84
        @test iso4217num(:USD) == 840
        @test iso4217num(:XPF) == 953
        @test iso4217num(Monetary{:XAF}) == 950
        @test iso4217num(Monetary{:XOF, BigInt}) == 952
    end

    @testset "Alphabetic Code" begin
        @test iso4217alpha(:DJF) == "DJF"
        @test iso4217alpha(Monetary{:BND, BigInt}) == "BND"
    end
end

@testset "Symbols" begin
    @test shortsymbol(:USD) == "\$"
    @test shortsymbol(:CAD) == "\$"
    @test shortsymbol(100EUR) == "€"
    @test shortsymbol(Monetary{:GBP}) == "£"
    @test shortsymbol(Monetary{:AUD, BigInt, 4}) == "\$"

    @test longsymbol(:USD) == "US\$"
    @test longsymbol(:CAD) == "CA\$"
    @test longsymbol(100EUR) == "€"
    @test longsymbol(Monetary{:GBP}) == "GB£"
    @test longsymbol(Monetary{:AUD, BigInt, 4}) == "AU\$"
end

# Currency
@testset "currency()" begin
    @test currency(2GBP) == :GBP
    @test currency(zero(Monetary{:CNY})) == :CNY
end

# Default precision
@testset "decimals()" begin
    @test decimals(:USD) == 2
    @test decimals(:JPY) == 0
    @test decimals(Monetary{:USD, BigInt}) == 2
    @test decimals(Monetary{:JPY, Int, 4}) == 4
    @test decimals(:XAU) == -1
    @test decimals(Monetary(:XAU; precision=4)) == 4
    @test decimals(Monetary{:XAU, Int, 3}) == 3
end

# Decimals
@testset "int()" begin
    @test int(-USD) == -100
    @test int(100JPY) == 100
    @test int(100USD) == 10000
    @test int(Monetary(:USD, 25000; precision=3)) == 25000
    @test int(one(Monetary{:USD, Int, 6})) == 1000000
    @test int(zero(Monetary{:USD, Int, 8})) == 0
end

end  # testset Data Access
