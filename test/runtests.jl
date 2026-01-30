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
    res = Fisher(bv1, bv2)

    @test pvalue(res) == 1.0

    bv1_rand = BitVector(rand(Bool, 1000))
    bv2_rand = BitVector(rand(Bool, 1000))
    res = Fisher(bv1_rand, bv2_rand)
    # в этом случае step почему-то получается 2
    @test 
end