using Currencies: Currency, symbol, currency, unit, name, code, _currency_data
using Test

currencies = ((:USD, 2, 840, "US Dollar"),
              (:EUR, 2, 978, "Euro"),
              (:JPY, 0, 392, "Yen"),
              (:JOD, 3, 400, "Jordanian Dinar"),
              (:CNY, 2, 156, "Yuan Renminbi"))

# This just makes sure that the data was loaded and at least some basic values are set as expected
@testset "Basic currencies" begin
    for (s, u, c, n) in currencies
        ccy = Currency{s}()
        @test currency(s) == ccy
        @test symbol(ccy) == s
        @test unit(ccy) == u
        @test name(ccy) == n
        @test code(ccy) == c
    end
end

# This makes sure that the values are within expected ranges
@testset "Validation" begin
    @test length(_currency_data) >= 155
    for (sym, ccy) in _currency_data
        (cur, uni, cod, nam) = ccy
        @test symbol(cur) == sym
        @test length(string(sym)) == 3
        @test uni >= 0
        @test 0 < cod < 2000
        @test length(nam) < 40
    end
end
