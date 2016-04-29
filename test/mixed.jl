# Tests for mixed arithmetic
@testset "Mixed" begin

@testset "Mixed Arithmetic" begin
    @test 1.01USD + Monetary(:USD; storage=BigInt) == 2.01USD
    @test 1.01USD ÷ Monetary(:USD; storage=BigInt) == 1
    @test 1.01USD % Monetary(:USD; storage=BigInt) == 0.01USD
end

@testset "Mixed Comparison" begin
    @test 1.01USD > Monetary(:USD; storage=BigInt)
    @test 1.01USD > Monetary(:USD; storage=BigInt, precision=4)
    @test 0.99USD < Monetary(:USD; storage=BigInt)
    @test 0.99USD < Monetary(:USD; storage=BigInt, precision=4)
    @test USD == Monetary(:USD; storage=BigInt)
    @test USD == Monetary(:USD; storage=BigInt, precision=4)

    @test USD ≠ CAD
    @test 0USD == 0CAD  # NB: unexpected?
end

@testset "Type Safety" begin
    @test_throws MethodError 1.01USD > CAD
    @test_throws MethodError 1.01USD + CAD
end

end  # testset Monetary
