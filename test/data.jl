## Tests relating to data integrity. ##

@testset "Data" begin
    # long symbols should be unique
    alllongsymbols = values(Currencies.LONG_SYMBOL)
    @test length(Set(alllongsymbols)) == length(alllongsymbols)

    # symbols should all be registered currencies
    registeredcurrencies = keys(Currencies.DATA)
    for sym in keys(Currencies.SHORT_SYMBOL)
        @test sym ∈ registeredcurrencies
    end
    for sym in keys(Currencies.LONG_SYMBOL)
        @test sym ∈ registeredcurrencies
    end

    # locale keys should be registered currencies, and value :before or :after
    for (sym, val) in Currencies.LOCAL_SYMBOL_LOCATION
        @test sym ∈ registeredcurrencies
        @test val ∈ (:before, :after)
    end
end
