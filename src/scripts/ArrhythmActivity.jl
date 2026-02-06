using XMLDict
using TimeSamplings
using OrderedCollections

include("Markups.jl")
export Markup

path = "C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest\\Ishem_Arithm.avt"

# function get_load_bitvec(mkp::Markup,
#     len::Int = length(mkp.trends.hr60),
#     target::T = ts.DownSampler(mkp.exam.fs_base * 60)) where T <: ts.AbstractSampler

#     samp10s = ts.DownSampler(mkp.exam.fs_base * 10)

#     motion_10 = mkp.periods.motion_bitvec10
#     walking_10 = mkp.periods.walking_bitvec10
#     len_10 = min(length(motion_10), length(walking_10))

#     load_target = falses(len)
#     for k in 1:len_10 # проход по индексам 10
#         i0 = samp10s[k] # берем начало интервала
#         i1 = samp10s[k+1] # берем конец интервала
#         d = target(i0 : i1-1) # находим индексы 60 которые лежат в интервале
#         load_target[d] .|= motion_10[k] | walking_10[k] # присваиваем значение по всем индексам 60
#     end
    
#     if mkp.periods.act_periods !== nothing
#         for ps in mkp.periods.act_periods
#             ps.type[1] == "Activity/D.A" || continue
#             for p in ps
#                 s_dcm = target(p.ibeg : p.iend) 
#                 load_target[s_dcm] .= true
#             end
#         end
#     end
#     return load_target
# end

# function get_senses_bitvecs(mkp::Markup,
#     len::Int = length(mkp.trends.hr60),
#     target::ts.AbstractSampler = ts.DownSampler(mkp.exam.fs_base * 60))

#     senses = falses(len)
#     each_sense = OrderedDict{String, BitVector}()

#     if mkp.periods.act_periods !== nothing
#         for ps in mkp.periods.act_periods
#             name = get(schema.SENSE_DECODE, ps.type[1], "");
#             isempty(name) && continue
#             bitvec = falses(len)
#             for p in ps
#                 s_dcm = target(p.ibeg : p.iend)
#                 bitvec[s_dcm] .= true
#                 senses[s_dcm] .= true
#             end
#             each_sense[name] = bitvec
#         end
#     end
#     return senses, each_sense
# end

# function get_arr_bitvec(mkp::Markup,
#     to::String)
#     if to == "QRS"
#         bv = falses(length(mkp.arrs[1].BitSet))
#         for (i, el) in enumerate(mkp.arrs[1].BitSet)
#             if !el
#                 bv[i] = true
#             end
#         end
#         return bv
#     elseif to == "10"
#         bv = falses(length(mkp.trends.h10))
#         point_sampler = EventSampler(mkp.qrs.timeQ)
#         target = DownSampler(mkp.exam.fs_base * 10)
        
#     end
    
# end

function get_bitvecs(mkp::Markup, marker::String)
    arr_qrs = falses(length(mkp.arrs[1].BitSet))
    for (i, el) in enumerate(mkp.arrs[1].BitSet)
        if !el
            arr_qrs[i] = true
        end
    end

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
        error("Wrong marker")
    end
    
    return arr, load, sense
end

# function get_load_bitvec_10s(mkp::Markup)
#     load = mkp.periods.motion_bitvec10 .| mkp.periods.walking_bitvec10
#     return load
# end

function qrs2int(bv_qrs::BitVector, mkp::Markup, step::Int, len_bv_s::Int = length(mkp.trends.hr10))
    if step == 60
        len_bv_s = length(mkp.trends.hr60)
    end
    bv_s = falses(len_bv_s)
    trues_qrs = findall(bv_qrs)
    index_qrs_s = (int).(mkp.qrs.timeQ ./ (mkp.exam.fs_base * step)) .+ 1

    for el in trues_qrs
        bv_s[index_qrs_s[el]] = true
    end

    return bv_s
end

function int10s2qrs(bv_10s::BitVector, mkp::Markup)
    bv_qrs = falses(mkp.qrs.timeQ)
    index_qrs_10s = (int).(mkp.qrs.timeQ ./ (mkp.exam.fs_base * 10)) .+ 1

    for (i, el) in enumerate(index_qrs_10s)
        bv_qrs[i] = bv_10s[el]
    end

    return bv_qrs
end

function int10s2int60s(bv_10s::BitVector, mkp::Markup)
    return qrs2int(int10s2qrs(bv_10s, mkp), mkp, 60)
end

# function get_senses_bitvec(mkp::Markup, type::String = "QRS")
#     senses = mkp
#     if type == "QRS"

#     end
# end

function get_activity_bitvec_qrs(mkp::Markup)
    act = mkp.periods.act_periods
    len = length(mkp.qrs.timeQ)
    sampler = EventSampler(mkp.qrs.timeQ)
    activity = falses(len)
    senses = falses(len)

    for el in act
        if occursin("Activity/D.A", el.type[1])
            bv = ibeg_iend2bv_qrs(el.ibeg[1], el.iend[1], len, sampler)
            activity .|= bv
        elseif occursin("Sensation", el.type[1])
            bv = ibeg_iend2bv_qrs(el.ibeg[1], el.iend[1], len, sampler)
            senses .|= bv
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

# mkp = Markup(path)
# # length(mkp.arrs[1].BitSet)
# mkp.exam.len_points

# activity, senses = get_activity_bitvec(mkp)
# println(count(activity))
# println(count(senses))