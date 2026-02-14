struct CircArr
    day_var::Number
    sleep_var::Number
    arr_day::Int
    arr_sleep::Int
    reliability::Bool
    result::String
    invalid::Bool

    function CircArr(mkp::Markup)
        sleep_ibeg = mkp.periods.sleep_periods.ibeg[1]
        sleep_iend = mkp.periods.sleep_periods.iend[1]
        arr = mkp.qrs.timeQ .* Int.(mkp.arrs[1].BitSet)
        filter!(!=(0), arr)
        hour = Int(mkp.exam.fs_base * 3600)
        len = mkp.exam.len_points

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

        day_var_vec = get_var(arr_day_vec, len - sleep_iend + sleep_ibeg, hour)
        sleep_var_vec = get_var(arr_sleep_vec, sleep_iend - sleep_ibeg, hour)

        if any(!isfinite, day_var_vec) | any(!isfinite, sleep_var_vec)
            return new(0, 0, 0, 0, false, "undefined", true)
        end

        day_var = _mean(day_var_vec)
        sleep_var = _mean(sleep_var_vec)

        rel = tTestStudent(day_var_vec, sleep_var_vec)
        res = "undefined"
        if rel
            res = day_var > sleep_var ? "day" : "night"
        end

        return new(day_var, sleep_var, arr_day, arr_sleep, rel, res, false)
    end
end

function Base.show(io::IO, res::CircArr)
    println(io, "Статистическая оценка циркадной аритмии")
    if res.invalid
        println(io, "Невозможно определить тип, аритмии слишком редки")
        return nothing
    end
    println(io, "Аритмий днем: ", res.arr_day)
    println(io, "Аритмий ночью: ", res.arr_sleep)
    println(io, "Дневная среднечасовая вариабельность: ", res.day_var)
    println(io, "Ночная среднечасовая вариабельность: ", res.sleep_var)

    if res.reliability
        print(io, "Различия СВ достоверны, тип аритмии определен как ")
        if res.result == "day"
            println("дневной")
        else
            println("ночной")
        end
    else 
        println(io, "Различия СВ недостоверны для определения типа аритмии")
    end
end

function get_var(arr::Vector, len::Int, hour::Int)
    hours_vec = Int[]
    for i in 0:hour:len
        if i != 0
            push!(hours_vec, i)
        end
    end
    
    if !any(!=(0), hours_vec)
        return zeros(length(hours_vec) - 1)
    end

    arr_in_hour = zeros(length(hours_vec))
    j = 1
    k = 0
    for el in arr
        if el < hours_vec[j]
           k += 1
        else
            arr_in_hour[j] = k
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

    return var
end

function _mean(v::Vector)
    sum = 0
    for el in v
        sum += el
    end
    return sum / length(v)
end