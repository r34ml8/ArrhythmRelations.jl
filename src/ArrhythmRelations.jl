module ArrhythmRelations

include("scripts/Markups.jl")
export Markup

include("scripts/ArrhythmActivity.jl")
export get_bitvecs

include("scripts/StatTests.jl")
export Fisher, chi2test, binomtest,
    percenttest, Stats, get_stats

include("scripts/FormTable.jl")
export form_table, add_row

end
