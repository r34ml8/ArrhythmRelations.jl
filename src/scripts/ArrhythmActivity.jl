using XMLDict
using TimeSamplings

include("Markups.jl")
export Markup

path = "C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest\\Ishem_Arithm.avt\\AlgResult.xml"

function get_activity_bitvec(mkp::Markup)
    act = mkp.periods.act_periods
    len = length(mkp.qrs.timeQ)
    sampler = EventSampler(mkp.qrs.timeQ)
    activity = falses(len)
    senses = falses(len)
    
    for el in act
        bv = int2bitvec(el.ibeg, el.iend, len, sampler)
        if occursin("Activity", el.type)
            activity .|= bv
        elseif occursin("Sensation", el.type)
            senses .|= bv
        end
    end

    return activity, senses
end

function int2bitvec(ibeg::Int, iend::Int, len::Int, sampler::EventSampler)
    i_qrs = sampler(ibeg:iend)
    bitvec = falses(len)
    # если возвращает range ?
    bitvec[i_qrs] = trues(length(i_qrs))
    return bitvec
end