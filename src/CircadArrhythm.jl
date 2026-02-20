module CircadArrhythm

using Printf

using ..StatTests
using ..Markups

struct CircArr
    day_var_V::Number
    sleep_var_V::Number
    arr_day_V::Int
    arr_sleep_V::Int
    reliability_V::Bool
    result_V::String

    day_var_S::Number
    sleep_var_S::Number
    arr_day_S::Int
    arr_sleep_S::Int
    reliability_S::Bool
    result_S::String

    function CircArr(mkp::Markup)
        sleep_ibeg = mkp.periods.sleep_periods.ibeg[1]
        sleep_iend = mkp.periods.sleep_periods.iend[1]
        hour = Int(mkp.exam.fs_base * 3600)
        len = mkp.exam.len_points

        arr_V, arr_S = get_arr(mkp)
        return new(findCircadian(mkp, arr_V, sleep_ibeg, sleep_iend, hour, len)...,
            findCircadian(mkp, arr_S, sleep_ibeg, sleep_iend, hour, len)...)
    end
end

function Base.show(io::IO, res::CircArr)
    println(io, "Статистическая оценка циркадной динамики желудочковых аритмий")

    if res.result_V == "undefined"
        println(io, "Невозможно определить тип, аритмии слишком редки")
    else
        println(io, "Аритмий днем: ", res.arr_day_V)
        println(io, "Аритмий ночью: ", res.arr_sleep_V)
        println(io, "Дневная среднечасовая вариабельность: ", @sprintf "%.3f" res.day_var_V)
        println(io, "Ночная среднечасовая вариабельность: ", @sprintf "%.3f" res.sleep_var_V)
        println(io, "Отношение дневной СВ к ночной: ", @sprintf "%.3f" res.day_var_V / res.sleep_var_V)

        if res.result_V == "day"
            println(io, "Различия СВ достоверны, тип аритмии определен как дневной")
        elseif res.result_V == "night"
            println(io, "Различия СВ достоверны, тип аритмии определен как ночной")
        else
            println(io, "Различия СВ недостоверны или незначительны, тип аритмии определен как смешанный")
        end
    end

    println(io, "Статистическая оценка циркадной динамики наджелудочковых аритмий")

    if res.result_S == "undefined"
        println(io, "Невозможно определить тип, аритмии слишком редки")
        return nothing
    else
        println(io, "Аритмий днем: ", res.arr_day_S)
        println(io, "Аритмий ночью: ", res.arr_sleep_S)
        println(io, "Дневная среднечасовая вариабельность: ", @sprintf "%.3f" res.day_var_S)
        println(io, "Ночная среднечасовая вариабельность: ", @sprintf "%.3f" res.sleep_var_S)
        println(io, "Отношение дневной СВ к ночной: ", @sprintf "%.3f" res.day_var_S / res.sleep_var_S)

        if res.result_S == "day"
            println(io, "Различия СВ достоверны, тип аритмии определен как дневной")
        elseif res.result_S == "night"
            println(io, "Различия СВ достоверны, тип аритмии определен как ночной")
        else
            println(io, "Различия СВ недостоверны или незначительны, тип аритмии определен как смешанный")
        end
    end
end

function findCircadian(mkp::Markup, _arr::BitVector, sleep_ibeg::Int, sleep_iend::Int, hour::Int, len::Int)
    arr = mkp.qrs.timeQ .* Int.(_arr)
    filter!(!=(0), arr)

    arr_day_vec = filter(!in(sleep_ibeg:sleep_iend), arr)
    for el in arr_day_vec
        if el > sleep_iend
            el -= sleep_iend - sleep_ibeg
        end
    end
    arr_day = length(arr_day_vec)

    arr_sleep_vec = filter(in(sleep_ibeg:sleep_iend), arr)
    arr_sleep_vec .-= sleep_ibeg
    arr_sleep = length(arr_sleep_vec)

    day_arr_in_hour, day_var_vec = get_var(arr_day_vec, len - sleep_iend + sleep_ibeg, hour)
    sleep_arr_in_hour, sleep_var_vec = get_var(arr_sleep_vec, sleep_iend - sleep_ibeg, hour)

    if _mean(vcat(day_arr_in_hour, sleep_arr_in_hour)) < 30
        return 0, 0, 0, 0, false, "undefined"
    end

    day_var = _mean(day_var_vec)
    sleep_var = _mean(sleep_var_vec)

    rel = tTestStudent(day_var_vec, sleep_var_vec)
    res = "mixed"
    if day_var / sleep_var <= 0.6
        res = "night"
    elseif day_var / sleep_var >= 1.5
        res = "day"
    end

    if !rel
        res = "mixed"
    end

    return day_var, sleep_var, arr_day, arr_sleep, rel, res
end

function get_var(arr::Vector, len::Int, hour::Int)
    hours_vec = Int[]
    for i in 0:hour:len
        if i != 0
            push!(hours_vec, i)
        end
    end

    arr_in_hour = ones(length(hours_vec))
    j = 1
    k = 0
    for el in arr
        if el < hours_vec[j]
           k += 1
        else
            arr_in_hour[j] = k > 0 ? k : 1
            while (j < length(hours_vec)) & (el > hours_vec[j])
                j += 1
            end
            k = 1
        end
    end

    var = zeros(length(arr_in_hour) - 1)
    for i in eachindex(var)
        var[i] = arr_in_hour[i] < arr_in_hour[i + 1] ? arr_in_hour[i + 1] / arr_in_hour[i] : arr_in_hour[i] / arr_in_hour[i + 1]
    end

    return arr_in_hour, var
end

function _mean(v::Vector)
    sum = 0
    for el in v
        sum += el
    end
    return sum / length(v)
end

function get_arr(mkp::Markup)
    arr_V = falses(length(mkp.arrs[1].BitSet))
    arr_S = falses(length(mkp.arrs[1].BitSet))

    for (i, el) in enumerate(mkp.arrs)
        if occursin(r"vV|rV", el.Code)
            arr_V .|= el.BitSet
        elseif occursin(r"vS|vA|vW|vB|rF|rS", el.Code)
            arr_S .|= el.BitSet
        end
    end
    
    return arr_V, arr_S
end

end