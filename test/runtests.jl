using ArrhythmRelations
using Test
using Random

@testset "ArrhythmRelations.jl" begin
    path = "C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest"
    folders = ["ChildArithm.avt", "Ishem_Arithm.avt", "ReoBreath.avt", "Seminar_AD_FP.avt", "VMT_Arrh_101159.avt"]
    form_table_arr_act()
    for el in folders
        mkp = Markup(path * "\\" * el)
        add_row_arr_act(el, StatsArrAct(mkp, "load"))
        add_row_arr_act(el, StatsArrAct(mkp, "sense"))
    end
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