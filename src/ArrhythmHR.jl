module ArrhythmHR

using ..StatTests
using ..Markups
# индивидуальный подбор окна с поправкой бонферрони + скользящее окно

struct ArrHR
    arr::Vector{Tuple{String, BitVector}}
    arrV::BitVector
    arrS::BitVector
    hr_10::Vector{Int}
    hr_60::Vector{Int}

    function ArrHR(mkp::Markup)
        # arr_10 = qrs2int.(mkp.arrs.BitSet, mkp, 10)
        # arr = [(mkp.arrs[i].Code, arr_10) for i in eachindex(mkp.arrs)]
        
        _arrV, _arrS = get_arr(mkp)
        arrV = qrs2int(_arrV, mkp, 10)
        arrS = qrs2int(_arrS, mkp, 10)        

        hr_10 = mkp.trends.hr10

        for el in hr_10
            if el < 0
                el = 90
            end
        end

        hr_60 = mkp.trends.hr60

        return new([], arrV, arrS, hr_10, hr_60)
    end
end

end