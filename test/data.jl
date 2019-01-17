## Tests relating to data integrity. ##

import Currencies.CurrenciesBase: LONG_SYMBOL, ISO4217, SHORT_SYMBOL, LOCAL_SYMBOL_LOCATION

@testset "Data" begin

# long symbols should be unique
alllongsymbols = values(LONG_SYMBOL)
@test length(Set(alllongsymbols)) == length(alllongsymbols)

# symbols should all be registered currencies
registeredcurrencies = keys(ISO4217)
for sym in keys(SHORT_SYMBOL)
    @test sym ∈ registeredcurrencies
end
for sym in keys(LONG_SYMBOL)
    @test sym ∈ registeredcurrencies
end

# locale keys should be registered currencies, and value :before or :after
for (sym, val) in LOCAL_SYMBOL_LOCATION
    @test sym ∈ registeredcurrencies
    @test val ∈ (:before, :after)
end

end  # @testset "Data"
