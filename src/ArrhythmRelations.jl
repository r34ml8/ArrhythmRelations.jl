module ArrhythmRelations

using HypothesisTests

include("scripts/Markups.jl")
export Markup

include("scripts/StatTests.jl")
export Fisher

include("scripts/ArrhythmActivity.jl")
export get_bitvecs

# path = "C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest\\Ishem_Arithm.avt"
# mkp = Markup(path)
# arr, load, sense = get_bitvecs(mkp, "60")
# println(Fisher(arr, sense))

end
