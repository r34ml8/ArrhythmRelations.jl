using ArrhythmRelations
using Test
using Random

@testset "ArrhythmRelations.jl" begin
    # Write your tests here.
end

Random.seed!(22)

@testset "StatTests.jl" begin
    bv1 = BitVector([1, 0, 1, 0, 1])
    bv2 = BitVector([1, 0, 0, 1, 1])
    res, _ = Fisher(bv1, bv2)
    @test pvalue(res) == 1.0

    bv1_rand = BitVector(rand(Bool, 1000))
    bv2_rand = BitVector(rand(Bool, 1000))
    _, step = Fisher(bv1_rand, bv2_rand)
    @test step == 1

    bv1_2 = BitVector([1, 1, 0, 0, 1, 1, 1, 0])
    bv2_2 = BitVector([0, 1, 1, 0, 0, 0, 1, 1])
    _, step = Fisher(bv1_2, bv2_2)
    @test step == 2
end