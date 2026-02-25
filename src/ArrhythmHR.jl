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

        arr_qrs = mkp.arrs[1].BitSet 
        sampler = EventSampler(mkp.qrs.timeQ ./ (mkp.exam.fs_base * 10))
        arr_10 = falses(length(hr_10))
        for i in eachindex(hr_10)
            arr_10[i] = any(arr_qrs[sampler((i - 1):i)])
        end

        p_values = [get_p_least_squares(arr_10, hr_10, win) for win in windows]

        return new(p_values)
    end
end

Base.show(io::IO, res::ArrHR) = println(io, "p_values = ", res.p_values)


function get_p_least_squares(arr::BitVector, hr::Vector{Int64}, win::Int64)
    arr_windows = Int[]
    for (i, el) in enumerate(arr)
        if el & (i > win)
            if !any(arr[i - win:i - 1])
                push!(arr_windows, i - win)
            end
        end
    end

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

    # if length(arr_windows) <= length(empty_windows)
    #     empty_windows = sort(sample(empty_windows, length(arr_windows), replace=false))
    # end

    if (length(arr_windows) < 30) | (length(empty_windows) < 30)
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