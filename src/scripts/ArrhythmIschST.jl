struct ArrhythmIschST
    arr::BitVector
    ST::BitVector
    type::Vector{String}

    function ArrhythmIschST(mkp::Markup)
        ST_raw = mkp.periods.ST_periods
        len = length(mkp.qrs.timeQ)
        ST = falses(len)
        sampler = EventSampler(mkp.qrs.timeQ)
        type = Vector[]
        if !isnothing(ST_raw)
            for el in ST_raw
                ST .|= ibeg_iend2bv_qrs(el.ibeg[1], el.iend[1], len, sampler)
                if !(el.Type in type)
                    push!(type, el.Type)
                end
            end
        end

        arr_qrs = mkp.arrs[1].BitSet
        for el in mkp.arrs
            arr_qrs .| el.BitSet
        end
    end
end