module ArrhythmRelations

using StatsBase
using DSP
using Plots

# include("scripts/Markups.jl")
# export Markup

# include("scripts/StatTests.jl")
# export Fisher

# include("scripts/ArrhythmActivity.jl")
# export get_bitvecs

# include("scripts/FormTable.jl")
# export form_table

# path = "C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest\\Ishem_Arithm.avt"
path = "C:\\Users\\rika\\Documents\\etu\\incart\\ArrhythmRelations.jl\\test\\data\\Ishem_Arithm.avt"
mkp = Markup(path)
arr, load, sense = get_bitvecs(mkp, "60")


end
