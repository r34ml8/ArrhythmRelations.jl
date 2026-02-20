module StatTests

using HypothesisTests
using Distributions

export Fisher, chi2test, binomtest,
    percenttest, StatsArrAct, BernoulliTest,
    tTestStudent

function Fisher(event1::BitVector, event2::BitVector)
    if length(event1) != length(event2)
        error("Размеры массивов отличаются.")
    end

    a = count(event1 .& event2)
    b = count(.!event1 .& event2)
    c = count(event1 .& .!event2)
    d = count(.!event1 .& .!event2)

    return pvalue(FisherExactTest(a, b, c, d)) < 0.05 
end

function chi2test(event1::BitVector, event2::BitVector)
    a = count(event1 .& event2)
    b = count(.!event1 .& event2)
    c = count(event1 .& .!event2)
    d = count(.!event1 .& .!event2)
    n = a + b + c + d

    e11 = (a + b) * (a + c) / n
    e12 = (a + b) * (b + d) / n
    e21 = (c + d) * (a + c) / n
    e22 = (c + d) * (b + d) / n

    chiq = (abs(e11 - a) - 0.5)^2 / e11 + (abs(e12 - b) - 0.5)^2 / e12 + (abs(e21 - c) - 0.5)^2 / e21 + (abs(e22 - d) - 0.5)^2 / e22

    return ccdf(Chisq(1), chiq) < 0.05
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

function BernoulliTest(n_total::Int, n_intersec::Int, p::Number, return_p::Bool = false)
    p = binomial(BigInt(n_total), n_intersec) * p^n_intersec * (1 - p)^(n_total - n_intersec)
    if return_p
        return p
    else
        return p < 0.05
    end
end

function tTestStudent(event1, event2)
    if any(!=(0), event1) & any(!=(0), event2)
        return pvalue(UnequalVarianceTTest(event1, event2)) < 0.05
    else
        return true
    end
end

end

# path = "C:\\Users\\rika\\Documents\\etu\\incart\\ArrhythmRelations.jl\\test\\data\\Ishem_Arithm.avt"
# mkp = Markup(path)
# arr, load, sense = get_bitvecs(mkp, "QRS")
# inv = Fisher(arr, sense)
# pvalue(inv)
# inv2 = chi2(arr, sense)
# pvalue(inv2)
# inv3 = binomtest(arr, load)
# pvalue(inv3)
# inv4 = percenttest(arr, load)
# inv4


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
