## Tests relating to data integrity. ##

@testset "Data" begin
    # long symbols should be unique
    alllongsymbols = values(Currencies.LONG_SYMBOL)
    @test length(Set(alllongsymbols)) == length(alllongsymbols)

    # symbols should all be registered currencies
    registeredcurrencies = keys(Currencies.DATA)
    for symbol in keys(Currencies.SHORT_SYMBOL)
        @test symbol ∈ registeredcurrencies
    end
    for symbol in keys(Currencies.LONG_SYMBOL)
        @test symbol ∈ registeredcurrencies
    end
end
