# Tests for README & Documentation Examples

# Manual control
money = 1USD
magn = money.val
symb = currency(money)
a = π^2 * magn

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
    @test Monetary(symb, round(Int, 100a)) == 9.87USD
    @test sum([k*v for (k, v) in change(167.25EUR)]) == 167.25EUR
end
