using Currencies
using Test

currencies = ((:USD, 2, 840, "US Dollar"),
              (:EUR, 2, 978, "Euro"),
              (:JPY, 0, 392, "Yen"),
              (:JOD, 3, 400, "Jordanian Dinar"),
              (:CNY, 2, 156, "Yuan Renminbi"))

# This just makes sure that the data was loaded and at least some basic values are set as expected
@testset "Basic currencies" begin
    for (s, u, c, n) in currencies
        ccy = Currency{s}
        @test currency(s) == ccy
        @test symbol(ccy) == s
        @test unit(ccy) == u
        @test name(ccy) == n
        @test code(ccy) == c
    end
end

# This makes sure that the values are within expected ranges
@testset "Validation" begin
    @test length(Currencies.allpairs()) >= 155
    for (s, (ct,u,c,n)) in Currencies.allpairs()
        ccy = Currency(s)
        @test symbol(ct) == s
        @test length(string(s)) == 3
        @test u >= 0
        @test 0 < c < 2000
        @test length(n) < 40
    end
end
