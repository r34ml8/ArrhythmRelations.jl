module ArrhythmRelations

using Printf

include("scripts/Markups.jl")
export Markup

include("scripts/GetBitvecs.jl")
export get_bitvecs_act_sense, ibeg_iend2bv_qrs

include("scripts/StatTests.jl")
export Fisher, chi2test, binomtest,
    percenttest, StatsArrAct, BernoulliTest,
    tTestStudent

include("scripts/FormTable.jl")
export form_table_arr_act, add_row_arr_act

include("scripts/ArrhythmIschST.jl")
export ArrhythmIschST

include("scripts/CircadArrhythm.jl")
export CircArr, get_var, _mean

end
