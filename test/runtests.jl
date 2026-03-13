using ArrhythmRelations
using Test
# using Random
using .ArrhythmRelations.StatTests
using TimeSamplings

path = pwd() * "\\test\\xmltest"
# path = "C:\\Users\\rika\\Documents\\etu\\incart\\ArrhythmRelations.jl\\test\\xmltest"
folders = ["ChildArithm.avt", "Ishem_Arithm.avt", "ReoBreath.avt", "Seminar_AD_FP.avt", "VMT_Arrh_101159.avt"]

# почему нули... и откуда наны возникают? типа ноль на ноль?
@testset "ArrhythmHR" begin
    for el in folders
        mkp = Markup(path * "\\" * el)
        try 
            ArrHR(mkp)
        catch e
            @error "Ошибка при создании ArrHR для $el"
            showerror(stdout, e, catch_backtrace())
        end
        io = IOBuffer()
        show(io, ArrHR(mkp))
        output = String(take!(io))
        println("Вывод для записи $el")
        println(output)
        @test occursin("p_values", output)
    end    
end

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
            ArrIschST(mkp)
        catch e
            suc = false
            @error "Ошибка при создании ArrIschST для $el"
            showerror(stdout, e, catch_backtrace())
        end
        @test suc
        if suc
            io = IOBuffer()
            show(io, ArrIschST(mkp))
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
        form_csv_arr_act(path)
    catch e
        suc = false
        showerror(stdout, e, catch_backtrace())
    end
    @test suc   
end

@testset "StatTests.jl" begin
    bv1 = BitVector([1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0])
    bv2 = BitVector([1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0])
    @test !StatTests.Fisher(bv1, bv2)
    @test !StatTests.chi2test(bv1, bv2)
    @test !StatTests.binomtest(bv1, bv2)
    @test !StatTests.percenttest(bv1, bv2)

    bv1 = BitVector([1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1])
    bv2 = BitVector([1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1])
    @test StatTests.Fisher(bv1, bv2)
    @test StatTests.chi2test(bv1, bv2)
    @test StatTests.binomtest(bv1, bv2)
    @test StatTests.percenttest(bv1, bv2)
end