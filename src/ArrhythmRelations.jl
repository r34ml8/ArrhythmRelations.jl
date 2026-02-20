module ArrhythmRelations

using Plots

include("Markups.jl")
using .Markups: Markup
export Markup 

include("StatTests.jl")

include("ArrhythmLoadSense/ArrhythmLoadSense.jl")
using .ArrhythmLoadSense: form_csv_arr_act
export form_csv_arr_act

include("ArrhythmIschST.jl")
using .ArrhythmIschST: ArrIschST
export ArrIschST

include("CircadArrhythm.jl")
using .CircadArrhythm: CircArr
export CircArr

include("ArrhythmHR.jl")
using .ArrhythmHR: ArrHR
export ArrHR

# path = "C:\\Users\\rika\\Documents\\etu\\incart\\ArrhythmRelations.jl\\test\\xmltest\\VMT_Arrh_101159.avt"
# mkp = Markup(path)
# ahr = ArrHR(mkp)

# arrh = Int.(ahr.arrV)
# pop!(arrh)

# h = ahr.hr_10
# for i in eachindex(h)
#     if h[i] < 0
#         h[i] = h[i - 1]
#     end
# end
# h_d = diff(h)
# plot(h_d[5000:5500], size=(1200, 800))
# plot!(arrh[5000:5500])

end
