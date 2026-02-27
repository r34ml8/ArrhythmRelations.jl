module ArrhythmHR

using TimeSamplings
using StatsBase

using ..StatTests
using ..Markups
# индивидуальный подбор окна с поправкой бонферрони + скользящее окно

const windows = [6, 12, 18, 30, 60, 90]

struct ArrHR
    # arr::BitVector
    # hr::Vector{Int}
    p_values::Vector{Float64}
    p_values_V::Vector{Float64}
    p_values_S::Vector{Float64}

    function ArrHR(mkp::Markup)     
        hr_10 = mkp.trends.hr10
        for (i, el) in enumerate(hr_10)
            if !(el isa Int64)
                if i > 1
                    hr_10[i] = hr_10[i - 1]
                else
                    hr_10[i] = hr_10[i + 1]
                end
            end
        end

        arr_V = falses(length(mkp.arrs[1].BitSet))
        arr_S = falses(length(mkp.arrs[1].BitSet))
        for (i, el) in enumerate(mkp.arrs)
            if occursin(r"vV|rV", el.Code)
                arr_V .|= el.BitSet
            elseif occursin(r"vS|vA|vW|vB|rF|rS", el.Code)
                arr_S .|= el.BitSet
            end
        end
 
        sampler = EventSampler(mkp.qrs.timeQ ./ (mkp.exam.fs_base * 10))
        arr_10 = qrs_to_10(mkp.arrs[1].BitSet, length(hr_10), sampler)
        arr_V_10 = qrs_to_10(arr_V, length(hr_10), sampler)
        arr_S_10 = qrs_to_10(arr_S, length(hr_10), sampler)

        empty_windows = [get_empty_windows(arr_10, win) for win in windows]
        p_values = [get_p_least_squares(arr_10, hr_10, windows[i], empty_windows[i]) for i in eachindex(windows)]
        p_values_V = [get_p_least_squares(arr_V_10, hr_10, windows[i], empty_windows[i]) for i in eachindex(windows)]
        p_values_S = [get_p_least_squares(arr_S_10, hr_10, windows[i], empty_windows[i]) for i in eachindex(windows)]

        return new(p_values, p_values_V, p_values_S)
    end
end

function Base.show(io::IO, res::ArrHR)
    println(io, "p_values = ", res.p_values)
    println(io, "p_values_V = ", res.p_values_V)
    println(io, "p_values_S = ", res.p_values_S)
end

qrs_to_10(arr_qrs::BitVector, len::Int, sampler::EventSampler) = [any(arr_qrs[sampler((i - 1):i)]) for i in 1:len]

function get_empty_windows(arr::Vector{Bool}, win::Int64)
    empty_windows = Int[]
    j = 1
    while j <= length(arr) - win * 3 + 1
        if !any(arr[j:j + win * 3 - 1])
            push!(empty_windows, j + win)
            j += win * 3
        else
            j += 1
        end
    end

    return empty_windows
end

function get_p_least_squares(arr::Vector{Bool}, hr::Vector{Int64}, win::Int64, empty_windows::Vector{Int64})
    arr_windows = Int[]
    for (i, el) in enumerate(arr)
        if el & (i > win)
            if !any(arr[i - win:i - 1])
                push!(arr_windows, i - win)
            end
        end
    end

    if (length(arr_windows) < 30) || (length(empty_windows) < 30)
        println("less than 30 windows")
        return NaN
    end

    coeffs_arr = [least_squares(hr[i:i + win - 1]) for i in arr_windows]
    filter!(!isnan, coeffs_arr) 
    coeffs_empty = [least_squares(hr[i:i + win - 1]) for i in empty_windows]
    filter!(!isnan, coeffs_empty)
    
    return tTestStudent(coeffs_arr, coeffs_empty)
end

function least_squares(vec::Vector{Int64})
    mult = [el * i for (i, el) in enumerate(vec)]
    square = vec .^ 2
    mean_x = mean(vec)

    return (mean(mult) - mean_x * mean(1:length(vec))) / (mean(square) - mean_x ^ 2)
end

end