using ArrhythmRelations
using Test
using Random

@testset "ArrhythmRelations.jl" begin
    # Write your tests here.
end

@testset "StatTests.jl" begin
    bv1 = BitVector([1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0])
    bv2 = BitVector([1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0])
    @test !Fisher(bv1, bv2)
    @test !chi2test(bv1, bv2)
    @test !binomtest(bv1, bv2)
    @test !percenttest(bv1, bv2)

    bv1 = BitVector([1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1])
    bv2 = BitVector([1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1])
    @test Fisher(bv1, bv2)
    @test chi2test(bv1, bv2)
    @test binomtest(bv1, bv2)
    @test percenttest(bv1, bv2)
end