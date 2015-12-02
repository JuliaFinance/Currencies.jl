using Currencies
using Base.Test

# Get currencies for tests
@usingcurrencies USD, CAD, EUR, GBP, JPY
@usingcurrencies CNY

# Monetary tests
include("monetary.jl")

# Basket tests
include("basket.jl")

# Tests for currencies (name, info, registration)
include("currencies.jl")

# investment
@test compoundfv(1000USD, 0.02, 12) == 1268.24USD
@test simplefv(1000USD, 0.04, 12) == 1480USD

# manual control (from README)
money = 1USD
magn = int(money)
symb = currency(money)
a = π * magn
b = π * a
@test Monetary(symb, round(Int, b)) == 9.87USD

# decimals
@test int(100JPY) == 100
@test int(100USD) == 10000

# give change (from README)
COINS = [500EUR, 200EUR, 100EUR, 50EUR, 20EUR, 10EUR, 5EUR, 2EUR, 1EUR, 0.5EUR,
    0.2EUR, 0.1EUR, 0.05EUR, 0.02EUR, 0.01EUR]
function change(amount::Monetary{:EUR,Int})
    coins = Dict{Monetary{:EUR,Int}, Int}()
    for denomination in COINS
        coins[denomination], amount = divrem(amount, denomination)
    end
    coins
end

sum([k*v for (k, v) in change(167.25EUR)])  # 167.25EUR

# Display
@test contains(string(1USD), "1.00")
@test contains(string(1JPY), "1")
@test contains(string(StaticBasket([1USD, 1CAD])), "CAD")
@test contains(string(DynamicBasket([1USD, 1CAD])), "USD")
@test !contains(string(StaticBasket([1USD, 1CAD, -1CAD])), "CAD")
