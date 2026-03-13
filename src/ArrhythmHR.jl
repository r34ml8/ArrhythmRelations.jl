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

    arrs::Vector{Vector{Float64}}
    arrs_V::Vector{Vector{Float64}}
    arrs_S::Vector{Vector{Float64}}
    
    empty::Vector{Vector{Float64}}
    empty_V::Vector{Vector{Float64}}
    empty_S::Vector{Vector{Float64}}

    arr_windows::Vector{Vector{Int}}
    arr_windows_V::Vector{Vector{Int}}
    arr_windows_S::Vector{Vector{Int}}

    empty_windows::Vector{Vector{Int}}
    # empty_windows_V::Vector{Vector{Int}}
    # empty_windows_S::Vector{Vector{Int}}
    

    function ArrHR(mkp::Markup)     
        hr_10 = mkp.trends.hr10
        
        arr_V = falses(length(mkp.arrs[1].BitSet))
        arr_S = falses(length(mkp.arrs[1].BitSet))
        for el in mkp.arrs
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
        p_values, arrs, empty, arr_windows = get_p(arr_10, hr_10, windows, empty_windows)
        p_values_V, arrs_V, empty_V, arr_windows_V = get_p(arr_V_10, hr_10, windows, empty_windows)
        p_values_S, arrs_S, empty_S, arr_windows_S = get_p(arr_S_10, hr_10, windows, empty_windows)

        
        return new(p_values, p_values_V, p_values_S,
        arrs, arrs_V, arrs_S,
        empty, empty_V, empty_S,
        arr_windows, arr_windows_V, arr_windows_S,
        empty_windows)
    end
end

function Base.show(io::IO, res::ArrHR)
    println(io, "p_values = ", res.p_values)
    println(io, "p_values_V = ", res.p_values_V)
    println(io, "p_values_S = ", res.p_values_S)
end

function get_p(arr_10, hr_10, windows, empty_windows)
    p_values = []
    arrs = []
    empties = []
    arr_windows = []
    for i in eachindex(windows)
        p, arr, empty, arr_wins = get_p_least_squares(arr_10, hr_10, windows[i], empty_windows[i])
        if !isnan(p)
            push!(arrs, arr)
            push!(empties, empty)
            push!(arr_windows, arr_wins)
        end
        push!(p_values, p)
    end

    return p_values, arrs, empties, arr_windows
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

    arr_windows = check_windows(hr, arr_windows, win)
    empty_windows = check_windows(hr, empty_windows, win)

    if (length(arr_windows) < 30) || (length(empty_windows) < 30)
        # println("less than 30 windows")
        return NaN, [NaN], [NaN], arr_windows
    elseif length(arr_windows) < length(empty_windows)
        empty_windows = sample(empty_windows, length(arr_windows), replace=false)
    else
        arr_windows = sample(arr_windows, length(empty_windows), replace=false)
    end

    coeffs_arr = [least_squares(hr[i:i + win - 1]) for i in arr_windows]
    # println(stderr, "coeffs_arr had zeros: ", count(==(0), coeffs_arr))
    coeffs_empty = [least_squares(hr[i:i + win - 1]) for i in empty_windows]
    # println(stderr, "coeffs_empty had zeros: ", count(==(0), coeffs_empty))


    return tTestStudent(coeffs_arr, coeffs_empty), coeffs_arr, coeffs_empty, arr_windows
end

function check_windows(hr::Vector{Int64}, windows::Vector{Int64}, win::Int)
    wrong = Int[]
    for (i, el) in enumerate(windows)
        if -2147483648 in hr[el:el + win - 1]
            push!(wrong, i)
        end
    end

    # println(stderr, wrong)
    
    # println(stderr, "before ", length(windows))
    deleteat!(windows, wrong)
    # println(stderr, "after ", length(windows))
    return windows
end

function least_squares(vec::Vector{Int64})
    # println(stderr, vec)
    x = 1:length(vec)
    mean_x = mean(x)
    cov_xy = mean(x .* vec) - mean_x * mean(vec)
    var_x = mean(x.^2) - mean_x^2

    return cov_xy / var_x 
end

end