using DataFrames, XLSX

function form_table()
    openxlsx("relations.xlsx", mode="w") do xf
        load = xf["Load"]
        sense = xf["Sense"]

        load["A1"] = "Filename"
        load["B1"] = "Fisher QRS"
        load["C1"] = "Fisher 10s"
        load["D1"] = "Fisher 60s"
        load["E1"] = "Chi2 QRS"
        load["F1"] = "Chi2 10s"
        load["G1"] = "Chi2 60s"
        load["H1"] = "Binom QRS"
        load["I1"] = "Binom 10s"
        load["J1"] = "Binom 60s"
        load["K1"] = "Percent QRS"
        load["L1"] = "Percent 10s"
        load["M1"] = "Percent 60s"

        sense["A1":"M1"] = load["A1":"M1"]
    end
end

function add_row(fn::String, res::Stats)
    openxlsx("relations.xlsx", mode="w") do xf
        sheet = xf["Load"]
        if res.marker == "sense"
            sheet = xf["Sense"]
        elseif res.marker != "load"
            error("Stats has wrong marker. Change it to load or sense.")
        end

        i = 1
        while sheet["A$i"] != ""
            i += 1
        end

        sheet["A$i"] = fn
        sheet["B$i"] = res.fisher_qrs ? "yes" : "no"
        sheet["C$i"] = res.fisher_10s ? "yes" : "no"
        sheet["D$i"] = res.fisher_60s ? "yes" : "no"
        sheet["E$i"] = res.chi2_qrs ? "yes" : "no"
        sheet["F$i"] = res.chi2_10s ? "yes" : "no"
        sheet["G$i"] = res.chi2_60s ? "yes" : "no"
        sheet["H$i"] = res.binom_qrs ? "yes" : "no"
        sheet["I$i"] = res.binom_10s ? "yes" : "no"
        sheet["J$i"] = res.binom_60s ? "yes" : "no"
        sheet["K$i"] = res.percent_qrs ? "yes" : "no"
        sheet["L$i"] = res.percent_10s ? "yes" : "no"
        sheet["M$i"] = res.percent_60s ? "yes" : "no"
    end
end