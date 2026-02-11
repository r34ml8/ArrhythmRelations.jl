using HypothesisTests
# using StatsBase
# using Plots

include("ArrhythmActivity.jl")
export get_bitvecs

include("Markups.jl")
export Markup

struct Stats
    type::String
    fisher_qrs::Bool
    fisher_10s::Bool
    fisher_60s::Bool
    chi2_qrs::Bool
    chi2_10s::Bool
    chi2_60s::Bool
    binom_qrs::Bool
    binom_10s::Bool
    binom_60s::Bool
    percent_qrs::Bool
    percent_10s::Bool
    percent_60s::Bool
end

# очень сомнительно, перепроверить ретерны

function Fisher(event1::BitVector, event2::BitVector)
    if length(event1) != length(event2)
        error("Размеры массивов отличаются.")
    end

    a = count(event1 .& event2)
    b = count(.!event1 .& event2)
    c = count(event1 .& .!event2)
    d = count(.!event1 .& .!event2)
    # @info a, b, c, d
    return pvalue(FisherExactTest(a, b, c, d)) < 0.05 
end

function chi2test(event1::BitVector, event2::BitVector)
    return pvalue(ChisqTest(event1, event2)) < 0.05
end

function binomtest(event::BitVector, bernoulli::BitVector)
    return pvalue(BinomialTest(count(event .& bernoulli), count(bernoulli))) < 0.05
end

function percenttest(event::BitVector, bernoulli::BitVector)
    if count(event .& bernoulli) / count(bernoulli) > 0.5
        return true
    else
        return false
    end
end

# можно и по-красивее

function get_stats(mkp::Markup, marker::String)
    if marker == "load"
        event1_qrs, event2_qrs, _ = get_bitvecs(mkp, "QRS")
        event1_10s, event2_10s, _ = get_bitvecs(mkp, "10")
        event1_60s, event2_60s, _ = get_bitvecs(mkp, "60")
    elseif marker == "sense"
        event1_qrs, _, event2_qrs = get_bitvecs(mkp, "QRS")
        event1_10s, _, event2_10s = get_bitvecs(mkp, "10")
        event1_60s, _, event2_60s = get_bitvecs(mkp, "60")
    else    
        error("Enter the correct marker: load or sense")
    end
    
    return Stats(marker,
        Fisher(event1_qrs, event2_qrs), Fisher(event1_10s, event2_10s), Fisher(event1_60s, event2_60s),
        chi2test(event1_qrs, event2_qrs), chi2test(event1_10s, event2_10s), chi2test(event1_60s, event2_60s),
        binomtest(event1_qrs, event2_qrs), binomtest(event1_10s, event2_10s), binomtest(event1_60s, event2_60s),
        percenttest(event1_qrs, event2_qrs), percenttest(event1_10s, event2_10s), percenttest(event1_60s, event2_60s)
        )
end

path = "C:\\Users\\rika\\Documents\\etu\\incart\\ArrhythmRelations.jl\\test\\data\\Ishem_Arithm.avt"
mkp = Markup(path)
arr, load, sense = get_bitvecs(mkp, "60")
inv = Fisher(arr, load)
pvalue(inv)
inv2 = chi2(arr, sense)
pvalue(inv2)
inv3 = binomtest(arr, load)
pvalue(inv3)
inv4 = percenttest(arr, load)
inv4


# эксперименты с кросс-корреляцией и чисткой данных

# вариант 1: что-то одно
# function load1(mkp::Markup, marker::String)
#     act_qrs, _ = get_activity_bitvec_qrs(mkp)
#     motion_10s = mkp.periods.motion_bitvec10
#     walking_10s = mkp.periods.walking_bitvec10
#     act, motion, walking = nothing, nothing, nothing
#     if marker == "QRS"
#         act = act_qrs
#         motion = int10s2qrs(motion_10s, mkp)
#         walking = int10s2qrs(walking_10s, mkp)
#     elseif marker == "10"
#         act = qrs2int(act_qrs, mkp, 10)
#         motion = motion_10s
#         walking = walking_10s
#     elseif marker == "60"
#         act = qrs2int(act_qrs, mkp, 60)
#         motion = int10s2int60s(motion_10s, mkp)
#         walking = int10s2int60s(walking_10s, mkp)
#     else
#         error("Enter the correct marker: QRS, 10 or 60")
#     end
    
#     return act, motion, walking
# end

# path = "C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest\\Ishem_Arithm.avt"
# mkp = Markup(path)

# arr, load, sense = get_bitvecs(mkp, "10")
# act, mot, wal = load1(mkp, "10")
# mw = wal .| act
# lag = -900:900
# plot(lag, crosscor(wal, arr, lag))
# plot!(lag, crosscor(wal, arr, lag))
# plot!(lag, crosscor(nw, arr, lag))

# function get_ints(wa::BitVector)
#     trues_wal = findall(wa)
#     wal_int = Int[]
#     j = 0
#     for (i, el) in enumerate(trues_wal)
#         if i != length(trues_wal)
#             if el == trues_wal[i + 1] - 1
#                 j += 1
#             elseif j != 0
#                 push!(wal_int, j)
#                 j = 0
#             end
#         end
#     end
#     return wal_int
# end

# function cut_out(bv::BitVector, minlen::Int)
#     i = 1
#     while i <= length(bv)
#         len = 0
#         while bv[i]
#            len += 1
#            i += 1 
#         end

#         if len < minlen 
#             bv[(i - len):(i - 1)] .= false
#         end

#         i += 1
#     end

#     return bv
# end

# nw = cut_out(wal, 10)
# println(get_ints(nw))
# println(get_ints(wal))
