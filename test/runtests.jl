using Currencies
import Currencies: unit, name, code, USD, PHP, HKD, SGD

using Test

currencies = [USD,PHP,HKD,SGD]
units = [2,2,2,2]
names = ["US Dollar","Philippine Piso","Hong Kong Dollar","Singapore Dollar"]
codes = [840,608,344,702]

for (ccy,u,n,c) in zip(currencies,units,names,codes)
    @test unit(ccy) == u
    @test name(ccy) == n
    @test code(ccy) == c
end
