using HypothesisTests

function Fisher(event1::BitVector, event2::BitVector)
    if length(event1) != length(event2)
        error("Размеры массивов отличаются.")
    end

    a = count(event1 .& event2)
    b = count(.!event1 .& event2)
    c = count(event1 .& .!event2)
    d = count(.!event1 .& .!event2)
    @info a, b, c, d
    return FisherExactTest(a, b, c, d)
end
