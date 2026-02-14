using TimeSamplings

struct ArrhythmIschST
    type::Vector{String}
    p_ST::Number
    arr_total_count::Int
    arr_on_ST_count::Int
    expect::Number
    odds_ratio::Number
    relation::Bool
    p::Number
    has_ST::Bool

    function ArrhythmIschST(mkp::Markup)
        ST_raw = mkp.periods.ST_periods
        len = length(mkp.qrs.timeQ)
        ST = falses(len)
        sampler = EventSampler(mkp.qrs.timeQ)
        type = String[]
        if !isnothing(ST_raw)
            for i in 1:length(ST_raw)
                ST .|= ibeg_iend2bv_qrs(ST_raw.ibeg[i], ST_raw.iend[i], len, sampler)
                if !(ST_raw.Type[i] in type)
                    push!(type, ST_raw.Type[i])
                end
            end
        else
            return new([], 0, 0, 0, 0, 0, false, 0, false)
        end

        arr = mkp.arrs[1].BitSet
        p_ST = count(ST) / length(ST)
        arr_total_count = count(arr)
        arr_on_ST_count = count(arr .& ST)
        
        p, expect, odds_ratio, relation = findRelationArrST(p_ST, arr_total_count, arr_on_ST_count)

        return new(type, p_ST, arr_total_count, arr_on_ST_count, expect, odds_ratio, relation, p, true)
    end
end

function Base.show(io::IO, res::ArrhythmIschST)
    if res.has_ST
        println(io, "Анализ записи на наличие связи между аритмиями и ST периодами типа ", join(res.type, ", "))
        if res.relation
            println(io, "Связь обнаружена")
        else 
            println(io, "Связь не обнаружена")
        end
        println(io, "p_value = ", res.p)
        println(io, "Всего аритмий: ", res.arr_total_count)
        println(io, "Аритмий на ST периоде: ", res.arr_on_ST_count)
        println(io, "Ожидаемое число аритмий: ", res.expect)
        println(io, "Отношение шансов: ", res.odds_ratio)
    else
        println(io, "Периоды ST не обнаружены")
    end
end

function findRelationArrST(p_ST::Number, n_total::Int, n_intersec::Int)
    p = BernoulliTest(n_total, n_intersec, p_ST, true)
    expected = n_total * p_ST
    odds_ratio = (n_intersec / n_total) / (expected / (n_total - expected))
    return p, expected, odds_ratio, p < 0.05
end
