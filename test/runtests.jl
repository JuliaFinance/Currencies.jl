using Currencies
using Test

symbols = [:USD,:PHP,:HKD,:SGD]
currencies = [Currency{s}() for s in symbols]
units = [2,2,2,2]
names = ["US Dollar","Philippine Piso","Hong Kong Dollar","Singapore Dollar"]
codes = [840,608,344,702]

for (currency,symbol,unit,name,code) in zip(currencies,symbols,units,names,codes)
    @test Currencies.symbol(currency) == symbol
    @test Currencies.unit(currency) == unit
    @test Currencies.name(currency) == name
    @test Currencies.code(currency) == code
end
