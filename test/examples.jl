# Tests for README & Documentation Examples

# Manual control
money = 1USD
magn = int(money)
symb = currency(money)
a = π * magn
b = π * a

# Give change
COINS = [500EUR, 200EUR, 100EUR, 50EUR, 20EUR, 10EUR, 5EUR, 2EUR, 1EUR, 0.5EUR,
    0.2EUR, 0.1EUR, 0.05EUR, 0.02EUR, 0.01EUR]
function change(amount::Monetary{:EUR,Int})
    coins = Dict{Monetary{:EUR,Int}, Int}()
    for denomination in COINS
        coins[denomination], amount = divrem(amount, denomination)
    end
    coins
end

@testset "Doc Examples" begin
    @test Monetary(symb, round(Int, b)) == 9.87USD
    @test sum([k*v for (k, v) in change(167.25EUR)]) == 167.25EUR
end

# Decimals
@testset "int()" begin
    @test int(100JPY) == 100
    @test int(100USD) == 10000
    @test int(Monetary(:USD, 25000; precision=3)) == 25000
    @test int(one(Monetary{:USD, Int, 6})) == 1000000
    @test int(zero(Monetary{:USD, Int, 8})) == 0
end
