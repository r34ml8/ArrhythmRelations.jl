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

# path = "C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest\\Ishem_Arithm.avt"
path = "C:\\Users\\rika\\Documents\\etu\\incart\\ArrhythmRelations.jl\\test\\data\\Ishem_Arithm.avt"
mkp = Markup(path)

form_table()
add_row("Ishem_Arithm.avt", get_stats(mkp, "sense"))

end
