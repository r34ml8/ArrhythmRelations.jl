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

path = "C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest\\ReoBreath.avt"
mkp = Markup(path)
for el in mkp.arrs
    println(el.Title)
end
# const SENSATIONS::Vector{NTuple{3, String}} = [
#     ("Sensation/A"    , "anxiety"             , "Тревога"),
#     ("Sensation/P"    , "pain"                , "Боль"),
#     ("Sensation/P.A"  , "pain_anginal"        , "Ангинозная боль"),
#     ("Sensation/P.B"  , "pain_behind_sternum" , "Боль за грудиной"),
#     ("Sensation/P.C"  , "pain_heart_area"     , "Боль в области сердца"),
#     ("Sensation/P.H"  , "headache"            , "Головная боль"),
#     ("Sensation/P.O"  , "other_pain"          , "Другая боль"),
#     ("Sensation/H"    , "arrhythmia"          , "Перебои (Аритмия)"),
#     ("Sensation/F"    , "palpitations"        , "Сердцебиение (Пульсация)"),
#     ("Sensation/T"    , "fatigue"             , "Усталость"),
#     ("Sensation/B"    , "dyspnea"             , "Одышка"),
#     ("Sensation/B.F"  , "rapid_breathing"     , "Учащенное дыхание"),
#     ("Sensation/B.D"  , "labored_breathing"   , "Затрудненное дыхание"),
#     ("Sensation/B.O"  , "other_dyspnea"       , "Другие варианты одышки"),
#     ("Sensation/W"    , "weakness"            , "Слабость"),
#     ("Sensation/W.I"  , "fainting"            , "Обморок"),
#     ("Sensation/W.S"  , "nausea"              , "Дурнота (Тошнота)"),
#     ("Sensation/W.C"  , "dizziness"           , "Головокружение (помрачение сознания)"),
#     ("Sensation/W.O"  , "other_weakness"      , "Другие варианты слабости"),
#     ("Sensation/E"    , "visual_disturbances" , "Нарушения зрения"),
#     ("Sensation/E.D"  , "eye_floaters"        , "«Мушки перед глазами»"),
#     ("Sensation/E.O"  , "other_disturbances"  , "Другие нарушения зрения"),
#     ("Sensation/O"    , "other_complaints"    , "Другие жалобы"),
# ]
# SENSE_DECODE = OrderedDict{String, String}(x[1] => x[2] for x in SENSATIONS)
# SENSE_ENCODE = OrderedDict{String, String}(x[2] => x[1] for x in SENSATIONS)
# SENSE_DESCRIBE = OrderedDict{String, String}(x[2] => x[3] for x in SENSATIONS)


# mkp = Markup("C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\src\\data")
# typeof(mkp.periods)
# mkp.periods
# sizeof(mkp.periods.motion_bitvec10)

# mkp = Markup("C:\\Users\\fifteen\\.julia\\dev\\ArrhythmRelations\\test\\xmltest\\Ishem_Arithm.avt")
# mkp.periods.act_periods