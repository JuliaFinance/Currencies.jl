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

# Valuation
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
@test valuate(rates_c, :USD, StaticBasket([200JPY, EUR])) == 3.3USD
@test valuate(rates_c, :JPY, 0USD) == 0JPY
@test valuate(rates_d, :CAD, 3.14CAD) == 3.14CAD
@test contains(string(rates_d), ":USD=>1.0")
@test contains(string(rates_d), ":CAD=>0.75")

@test_throws KeyError valuate(rates_a, :JPY, 100USD)

# Display
@test contains(string(1USD), "1.00")
@test contains(string(1JPY), "1")
@test contains(string(StaticBasket([1USD, 1CAD])), "CAD")
@test contains(string(DynamicBasket([1USD, 1CAD])), "USD")
@test !contains(string(StaticBasket([1USD, 1CAD, -1CAD])), "CAD")
