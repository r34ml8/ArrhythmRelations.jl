using ArrhythmRelations
using Test
using Random

path = "C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest"
folders = ["ChildArithm.avt", "Ishem_Arithm.avt", "ReoBreath.avt", "Seminar_AD_FP.avt", "VMT_Arrh_101159.avt"]

@testset "Circadian Arrhythmia" begin
    for el in folders
        local suc = true
        mkp = Markup(path * "\\" * el)
        try
            CircArr(mkp)
        catch e
            suc = false
            @error "Ошибка при создании CircArr для $el"
            showerror(stdout, e, catch_backtrace())
        end
        @test suc
        if suc
            io = IOBuffer()
            show(io, CircArr(mkp))
            output = String(take!(io))
            println("Вывод для записи $el")
            println(output)
            if el in ["Ishem_Arithm.avt", "ReoBreath.avt", "Seminar_AD_FP.avt"]
                @test occursin(" желудочковых аритмий\nНевозможно", output)
            else
                @test !occursin(" желудочковых аритмий\nНевозможно", output)
            end

            if el == "ReoBreath.avt"
                @test !occursin("наджелудочковых аритмий\nНевозможно", output)
            else
                @test occursin("наджелудочковых аритмий\nНевозможно", output)
            end
        end
    end
end

@testset "Arrhythmia/ST" begin
    for el in folders
        local suc = true
        mkp = Markup(path * "\\" * el)
        try
            ArrhythmIschST(mkp)
        catch e
            suc = false
            @error "Ошибка при создании ArrhythmIschST для $el"
            showerror(stdout, e, catch_backtrace())
        end
        @test suc
        if suc
            io = IOBuffer()
            show(io, ArrhythmIschST(mkp))
            output = String(take!(io))
            println("Вывод для записи $el")
            println(output)
            if el != "Ishem_Arithm.avt"
                @test output == "Периоды ST не обнаружены\n"
            else
                @test output != "Периоды ST не обнаружены\n"
            end
        end
    end
end

@testset "Arrhythmia/Activity" begin
    local suc = true
    try
        form_table_arr_act()
    catch
        suc = false
    end
    @test suc
    for el in folders
        mkp = Markup(path * "\\" * el)
        local suc = true
        try
            add_row_arr_act(el, StatsArrAct(mkp, "load"))
            add_row_arr_act(el, StatsArrAct(mkp, "sense"))
        catch
            suc = false
        end
        @test suc
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