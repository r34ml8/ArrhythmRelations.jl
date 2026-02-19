# from ReportConstructor.jl
using FileUtils
# using OrderedCollections

@kwdef mutable struct Markup
    path::String = ""
    patient = nothing
    exam = nothing
    qrs = nothing
    qrs_groups = nothing
    rhythms = nothing
    arrs = nothing
    trends = nothing
    periods = nothing

    function Markup(path::String)
        filexml = joinpath(path, "AlgResult.xml")
        doc = FileUtils.readxml(filexml)

        patient, exam = FileUtils.getxml_patient_exam(doc.root)
        qrs, meta = FileUtils.getxml_pqrst_anz(doc.root)
        qrs_groups = FileUtils.getxml_qrs_groups(doc.root)
        rhythms, arrs, _ = FileUtils.getxml_rhythms_arrs(doc.root)

        trends = FileUtils.getxml_trends(doc.root)
        periods = FileUtils.getxml_periods(doc.root)

        qrs_groups = filter(x->x.Count > 0, qrs_groups) 
        
        # ! выкусываем X из всех битовых массивов и комплексов
        is_X = broadcast(f->(f in (:ZX, :X, :XZ, :XC)), qrs.form)
        deleteat!(qrs, is_X)

        for r in rhythms
            deleteat!(r.BitSet, is_X)
        end
        for a in arrs
            deleteat!(a.BitSet, is_X)
        end

        return new(path, patient, exam, qrs, qrs_groups, rhythms, arrs, trends, periods)
    end
end

# path = "C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest\\ReoBreath.avt"
path = "C:\\Users\\rika\\Documents\\etu\\incart\\ArrhythmRelations.jl\\test\\xmltest\\Ishem_Arithm.avt"
mkp = Markup(path)
mkp.trends.hr10
