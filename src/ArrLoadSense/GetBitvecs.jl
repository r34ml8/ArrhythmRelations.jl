using TimeSamplings
# include("Markups.jl")
# export Markup
# path = "C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest\\Ishem_Arithm.avt"

function get_bitvecs_act_sense(mkp::Markup, marker::String)
    arr_qrs = mkp.arrs[1].BitSet

    act_qrs, sense_qrs = get_activity_bitvec_qrs(mkp)
    load_10s_from_motion = mkp.periods.motion_bitvec10 .| mkp.periods.walking_bitvec10
    
    arr, load, sense = nothing, nothing, nothing
    if marker == "QRS"
        arr = arr_qrs
        load = int10s2qrs(load_10s_from_motion, mkp) .| act_qrs
        sense = sense_qrs
    elseif marker == "10"
        arr = qrs2int(arr_qrs, mkp, 10)
        load = load_10s_from_motion .| qrs2int(act_qrs, mkp, 10)
        sense = qrs2int(sense_qrs, mkp, 10)
    elseif marker == "60"
        arr = qrs2int(arr_qrs, mkp, 60)
        load = int10s2int60s(load_10s_from_motion, mkp) .| qrs2int(act_qrs, mkp, 60)
        sense = qrs2int(sense_qrs, mkp, 60)
    else
        error("Enter the correct marker: QRS, 10 or 60")
    end
    
    return arr, load, sense
end

function get_activity_bitvec_qrs(mkp::Markup)
    act = mkp.periods.act_periods
    len = length(mkp.qrs.timeQ)
    sampler = EventSampler(mkp.qrs.timeQ)
    activity = falses(len)
    senses = falses(len)

    if !isnothing(act)
        for el in act
            if occursin("Activity/D.A", el.type[1])
                bv = ibeg_iend2bv_qrs(el.ibeg[1], el.iend[1], len, sampler)
                activity .|= bv
            elseif occursin("Sensation", el.type[1])
                bv = ibeg_iend2bv_qrs(el.ibeg[1], el.iend[1], len, sampler)
                senses .|= bv
            end
        end
    end

    return activity, senses
end

function ibeg_iend2bv_qrs(ibeg::Int, iend::Int, len::Int, sampler::EventSampler)
    i_qrs = sampler(ibeg:iend)
    bitvec = falses(len)
    bitvec[i_qrs] = trues(length(i_qrs))
    return bitvec
end

function qrs2int(bv_qrs::BitVector, mkp::Markup, step::Int, len_bv_s::Int = length(mkp.trends.hr10))
    if step == 60
        len_bv_s = length(mkp.trends.hr60)
    end
    bv_s = falses(len_bv_s)
    trues_qrs = findall(bv_qrs)
    index_qrs_s = trunc.(Int, mkp.qrs.timeQ ./ (mkp.exam.fs_base * step)) .+ 1

    for el in trues_qrs
        bv_s[index_qrs_s[el]] = true
    end

    return bv_s
end

function int10s2qrs(bv_10s::BitVector, mkp::Markup)
    bv_qrs = falses(length(mkp.qrs.timeQ))
    index_qrs_10s = ceil.(Int, mkp.qrs.timeQ ./ (mkp.exam.fs_base * 10))

    for (i, el) in enumerate(index_qrs_10s)
        bv_qrs[i] = bv_10s[el]
    end

    return bv_qrs
end

function int10s2int60s(bv_10s::BitVector, mkp::Markup)
    return qrs2int(int10s2qrs(bv_10s, mkp), mkp, 60)
end

# mkp = Markup(path)
# typeof(mkp.periods.walking_bitvec10)
# a, l, s = get_bitvecs(mkp, "QRS")

# count(l)

# count(mkp.arrs[1].BitSet)