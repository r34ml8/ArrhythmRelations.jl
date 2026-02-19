module ArrhythmRelations

using Printf, Plots

include("Markups.jl")
export Markup

include("ArrLoadSense/GetBitvecs.jl")
export get_bitvecs_act_sense, ibeg_iend2bv_qrs,
    qrs2int

include("StatTests.jl")
export Fisher, chi2test, binomtest,
    percenttest, StatsArrAct, BernoulliTest,
    tTestStudent

include("ArrLoadSense/FormTable.jl")
export form_table_arr_act, add_row_arr_act

include("ArrhythmIschST.jl")
export ArrhythmIschST

include("CircadArrhythm.jl")
export CircArr, get_var, _mean, get_arr

include("ArrhythmHR.jl")
export ArrHR

path = "C:\\Users\\rika\\Documents\\etu\\incart\\ArrhythmRelations.jl\\test\\xmltest\\VMT_Arrh_101159.avt"
mkp = Markup(path)
ahr = ArrHR(mkp)

arrh = Int.(ahr.arrV)
pop!(arrh)

h = ahr.hr_10
for i in eachindex(h)
    if h[i] < 0
        h[i] = h[i - 1]
    end
end
h_d = diff(h)
plot(h_d[5000:5500], size=(1200, 800))
plot!(arrh[5000:5500])

end
