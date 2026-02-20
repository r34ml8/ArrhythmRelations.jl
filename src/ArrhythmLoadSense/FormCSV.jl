using XLSX
using DataFrames, CSV

function form_csv_arr_act(path::String)
    columns = [:filename, :fisher_qrs, :fisher_10s, :fisher_60s,
        :chi2_qrs, :chi2_10s, :chi2_60s, :binom_qrs, :binom_10s, :binom_60s,
        :percent_qrs, :percent_10s, :percent_60s]

    res_df = Dict("load" => DataFrame([[] for _ in columns], columns),
        "sense" => DataFrame([[] for _ in columns], columns))

    paths = readdir(path, join=true)
    filter!(isdir, paths)

    for el in paths
        mkp = Markup(el)

        for mode in ["load", "sense"]
            df = res_df[mode]
            res = StatsArrAct(mkp, mode)

            if !res.has_data
                continue
            end

            row = (
                filename = basename(el),
                fisher_qrs = res.fisher_qrs ? "ДА" : "НЕТ",
                fisher_10s = res.fisher_10s ? "ДА" : "НЕТ",
                fisher_60s = res.fisher_60s ? "ДА" : "НЕТ",
                chi2_qrs = res.chi2_qrs ? "ДА" : "НЕТ",
                chi2_10s = res.chi2_10s ? "ДА" : "НЕТ",
                chi2_60s = res.chi2_60s ? "ДА" : "НЕТ",
                binom_qrs = res.binom_qrs ? "ДА" : "НЕТ",
                binom_10s = res.binom_10s ? "ДА" : "НЕТ",
                binom_60s = res.binom_60s ? "ДА" : "НЕТ",
                percent_qrs = res.percent_qrs ? "ДА" : "НЕТ",
                percent_10s = res.percent_10s ? "ДА" : "НЕТ",
                percent_60s = res.percent_60s ? "ДА" : "НЕТ"
            )

            push!(df, row)
        end
    end

    CSV.write("relations_load.csv", res_df["load"])
    CSV.write("relations_sense.csv", res_df["sense"])

end

# function form_table_arr_act()
#     XLSX.openxlsx("relations.xlsx", mode="w") do xf
#         load = xf[1]
#         XLSX.rename!(load, "Load")
#         XLSX.addsheet!(xf, "Sense")

#         load["A1"] = "Filename"
#         load["B1"] = "Fisher QRS"
#         load["C1"] = "Fisher 10s"
#         load["D1"] = "Fisher 60s"
#         load["E1"] = "Chi2 QRS"
#         load["F1"] = "Chi2 10s"
#         load["G1"] = "Chi2 60s"
#         load["H1"] = "Binom QRS"
#         load["I1"] = "Binom 10s"
#         load["J1"] = "Binom 60s"
#         load["K1"] = "Percent QRS"
#         load["L1"] = "Percent 10s"
#         load["M1"] = "Percent 60s"

#         sense = xf[2]
#         sense["A1"] = "Filename"
#         sense["B1"] = "Fisher QRS"
#         sense["C1"] = "Fisher 10s"
#         sense["D1"] = "Fisher 60s"
#         sense["E1"] = "Chi2 QRS"
#         sense["F1"] = "Chi2 10s"
#         sense["G1"] = "Chi2 60s"
#         sense["H1"] = "Binom QRS"
#         sense["I1"] = "Binom 10s"
#         sense["J1"] = "Binom 60s"
#         sense["K1"] = "Percent QRS"
#         sense["L1"] = "Percent 10s"
#         sense["M1"] = "Percent 60s"
#     end
# end

# function add_row_arr_act(fn::String, res::StatsArrAct)
#     XLSX.openxlsx("relations.xlsx", mode="rw") do xf
#         if !res.has_data
#             return nothing
#         end
#         sheet = xf[1]
#         if res.type == "sense"
#             sheet = xf[2]
#         elseif res.type != "load"
#             error("Stats has wrong marker. Change it to load or sense.")
#         end

#         i = 1
#         while !ismissing(sheet["A$i"])
#             i += 1
#         end

#         sheet["A$i"] = fn
#         sheet["B$i"] = res.fisher_qrs ? "yes" : "no"
#         sheet["C$i"] = res.fisher_10s ? "yes" : "no"
#         sheet["D$i"] = res.fisher_60s ? "yes" : "no"
#         sheet["E$i"] = res.chi2_qrs ? "yes" : "no"
#         sheet["F$i"] = res.chi2_10s ? "yes" : "no"
#         sheet["G$i"] = res.chi2_60s ? "yes" : "no"
#         sheet["H$i"] = res.binom_qrs ? "yes" : "no"
#         sheet["I$i"] = res.binom_10s ? "yes" : "no"
#         sheet["J$i"] = res.binom_60s ? "yes" : "no"
#         sheet["K$i"] = res.percent_qrs ? "yes" : "no"
#         sheet["L$i"] = res.percent_10s ? "yes" : "no"
#         sheet["M$i"] = res.percent_60s ? "yes" : "no"
#     end
# end