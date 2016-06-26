## Tests relating to data integrity. ##

import Currencies.CurrencyData

@testset "Data" begin

# long symbols should be unique
alllongsymbols = values(CurrencyData.LONG_SYMBOL)
@test length(Set(alllongsymbols)) == length(alllongsymbols)

# symbols should all be registered currencies
registeredcurrencies = keys(CurrencyData.ISO4217)
for sym in keys(CurrencyData.SHORT_SYMBOL)
    @test sym ∈ registeredcurrencies
end
for sym in keys(CurrencyData.LONG_SYMBOL)
    @test sym ∈ registeredcurrencies
end

# locale keys should be registered currencies, and value :before or :after
for (sym, val) in CurrencyData.LOCAL_SYMBOL_LOCATION
    @test sym ∈ registeredcurrencies
    @test val ∈ (:before, :after)
end

end  # @testset "Data"
