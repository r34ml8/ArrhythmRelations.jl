module ArrhythmLoadSense

using ..StatTests
using ..Markups

struct StatsArrAct
    type::String
    has_data::Bool
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

    function StatsArrAct(mkp::Markup, marker::String)
        if marker == "load"
            event1_qrs, event2_qrs, _ = get_bitvecs_act_sense(mkp, "QRS")
            event1_10s, event2_10s, _ = get_bitvecs_act_sense(mkp, "10")
            event1_60s, event2_60s, _ = get_bitvecs_act_sense(mkp, "60")
        elseif marker == "sense"
            event1_qrs, _, event2_qrs = get_bitvecs_act_sense(mkp, "QRS")
            event1_10s, _, event2_10s = get_bitvecs_act_sense(mkp, "10")
            event1_60s, _, event2_60s = get_bitvecs_act_sense(mkp, "60")
        else    
            error("Enter the correct marker: load or sense")
        end
        
        has_data = count(event2_60s) == 0 ? false : true

        return new(marker, has_data,
            Fisher(event1_qrs, event2_qrs), Fisher(event1_10s, event2_10s), Fisher(event1_60s, event2_60s),
            chi2test(event1_qrs, event2_qrs), chi2test(event1_10s, event2_10s), chi2test(event1_60s, event2_60s),
            binomtest(event1_qrs, event2_qrs), binomtest(event1_10s, event2_10s), binomtest(event1_60s, event2_60s),
            percenttest(event1_qrs, event2_qrs), percenttest(event1_10s, event2_10s), percenttest(event1_60s, event2_60s)
            )
    end
end

include("GetBitvecs.jl")
export get_bitvecs_act_sense

include("FormCSV.jl")
export form_csv_arr_act

end