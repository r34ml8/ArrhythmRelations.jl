using HypothesisTests

function Fisher(event1::BitVector, event2::BitVector; step::Int64 = 0)
    if length(event1) != length(event2)
        error("Размеры массивов отличаются.")
    end

    if step == 0
        step1 = findMinDuration(event1)
        step2 = findMinDuration(event2)
        step = min(step1, step2)
        if step == 0
            step = max(step1, step2)
            if step == 0
                error("События отсутствуют.")
            end
        end
    end

    event1 = groupingBitVec(event1, step)
    event2 = groupingBitVec(event2, step)

    @info event1, event2

    a = count(event1 .& event2)
    b = count(.!event1 .& event2)
    c = count(event1 .& .!event2)
    d = count(.!event1 .& .!event2)
    @info a, b, c, d
    return FisherExactTest(a, b, c, d)
end

function findMinDuration(bitvec::BitVector)
    step = 0
    dur = 0

    for i in eachindex(bitvec)
        if bitvec[i]
            dur += 1
        elseif dur > 0
            if step == 0 || dur < step
                step = dur
            end
            dur = 0
        end
    end

    return step
end

function groupingBitVec(bitvec::BitVector, step::Int64)
    steps_range = 1:step:length(bitvec)
    new_bitvec = BitVector(undef, length(steps_range))

    for (i_new, i_old) in enumerate(steps_range)
        new_bitvec[i_new] = any(bitvec[i_old:(i_old + step - 1)])
    end

    return new_bitvec
end

bv1 = BitVector([1, 0, 1, 0, 1])
bv2 = BitVector([1, 0, 0, 1, 1])
testres = Fisher(bv1, bv2)
