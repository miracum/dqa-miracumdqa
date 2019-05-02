# by Lorenz Kapsner

library(jsonlite)


dt_patient.db <- 
  "SELECT
	patient_num       AS    patient_id, 
  birth_date::date  AS    birth_date, 
  sex_cd            AS    gender, 
  zip_cd            AS    zip_code
FROM
	i2b2miracum.patient_dimension
ORDER BY 
	patient_num;"


dt_visit.db <- 
  "SELECT
	patient_num       AS    patient_id,
  encounter_num     AS    encounter_id, 
  start_date::date  AS    encounter_start_date, 
  end_date::date    AS    encounter_end_date
FROM
  i2b2miracum.visit_dimension
ORDER BY 
  patient_num;"


dt_aitaa.db <- 
  "SELECT 
  encounter_num     AS    encounter_id, 
  nval_num          AS    age
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'FALL:AITAA'
GROUP BY
	encounter_num, patient_num, concept_cd, nval_num
ORDER BY
  encounter_num;"


dt_aijaa.db <- 
  "SELECT 
  encounter_num     AS    encounter_id, 
  nval_num          AS    age
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'FALL:AIJAA'
GROUP BY
	encounter_num, patient_num, concept_cd, nval_num
ORDER BY
  encounter_num;"


dt_aufnan.db <- 
  "SELECT
	encounter_num     AS    encounter_id, 
  concept_cd        AS    admission_occasion
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'AUFNAN%'
ORDER BY 
  encounter_num;"


dt_aufngr.db <- 
  "SELECT 
  encounter_num     AS    encounter_id, 
  concept_cd        AS    admission_reason
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'AUFNGR%'
ORDER BY 
  encounter_num;"


dt_entlgr.db <- 
  "SELECT 
  encounter_num     AS    encounter_id, 
  concept_cd        AS    discharge_reason
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'ENTLGR%'
ORDER BY 
  encounter_num;"


dt_beatmst.db <- 
  "SELECT 
  encounter_num     AS    encounter_id, 
  nval_num          AS    ventilation_hours
FROM 
	i2b2miracum.observation_fact 
WHERE 
	concept_cd LIKE 'FALL:BEATMST'
ORDER BY 
	encounter_num;"


dt_icd.db <- 
  "SELECT 
  encounter_num     AS    encounter_id, 
  concept_cd        AS    icd_code,
	modifier_cd       AS    diagnosis_type
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'ICD%'
ORDER BY
  encounter_num;"


dt_ops.db <- 
  "SELECT 
  encounter_num     AS    encounter_id, 
  concept_cd        AS    ops_code,
  start_date::date  AS    ops_date
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'OPS%'
ORDER BY
  encounter_num;"


dt_fab.db <- 
  "SELECT 
  encounter_num     AS    encounter_id, 
  tval_char         AS    department,
  start_date::date  AS    department_start_date, 
  end_date::date    AS    department_end_date
FROM 
	i2b2miracum.observation_fact
WHERE 
	concept_cd LIKE 'FACHABT%'
ORDER BY
	encounter_num;"


dt_pl_c5x.db <- 
  "SELECT 
  ob.encounter_num    AS    encounter_id, 
  ob.patient_num      AS    patient_id,
  ob.concept_cd       AS    icd_code,
  pa.sex_cd           AS    gender,
  regexp_matches(ob.concept_cd, 'ICD10:C5[1-8]', 'g') AS regex
FROM 
  i2b2miracum.observation_fact AS ob
LEFT OUTER JOIN 
  i2b2miracum.patient_dimension AS pa ON ob.patient_num = pa.patient_num
ORDER BY
  ob.encounter_num;"


dt_pl_c6x.db <- 
  "SELECT 
  ob.encounter_num    AS    encounter_id, 
  ob.patient_num      AS    patient_id,
  ob.concept_cd       AS    icd_code,
  pa.sex_cd           AS    gender,
  regexp_matches(ob.concept_cd, 'ICD10:C6[0-3]', 'g') AS regex
FROM 
  i2b2miracum.observation_fact AS ob
LEFT OUTER JOIN 
  i2b2miracum.patient_dimension AS pa ON ob.patient_num = pa.patient_num
ORDER BY
  ob.encounter_num;"


dt_pl_05xx.db <-
  "SELECT 
  ob.encounter_num    AS    encounter_id, 
  ob.patient_num      AS    patient_id,
  ob.concept_cd       AS    admission_reason,
  pa.sex_cd           AS    gender,
  regexp_matches(ob.concept_cd, 'AUFNGR:05', 'g') AS regex
FROM 
  i2b2miracum.observation_fact AS ob
LEFT OUTER JOIN 
  i2b2miracum.patient_dimension AS pa ON ob.patient_num = pa.patient_num
ORDER BY
  ob.encounter_num;"


dt_pl_o0099.db <-
  "SELECT 
  ob.encounter_num    AS    encounter_id, 
  ob.patient_num      AS    patient_id,
  ob.concept_cd       AS    icd_code,
  pa.sex_cd           AS    gender,
  regexp_matches(ob.concept_cd, 'ICD10:O[0-9]', 'g') AS regex
FROM 
  i2b2miracum.observation_fact AS ob
LEFT OUTER JOIN 
  i2b2miracum.patient_dimension AS pa ON ob.patient_num = pa.patient_num
ORDER BY
  ob.encounter_num;"



string_list <- list()


for (i in c("dt_patient.db", "dt_visit.db", "dt_aitaa.db", "dt_aijaa.db", "dt_aufnan.db", "dt_aufngr.db", "dt_entlgr.db", "dt_beatmst.db",
            "dt_icd.db", "dt_ops.db", "dt_fab.db", "dt_pl_c5x.db", "dt_pl_c6x.db", "dt_pl_05xx.db", "dt_pl_o0099.db")){
  print(i)
  string_list[[i]] <- eval(parse(text=i))
}

jsonlist <- toJSON(string_list, pretty = T, auto_unbox = F)
writeLines(jsonlist, "./_utilities/sql.JSON")


# # debugging
# txt <- fromJSON("./sql.JSON")
# txt$"dt_patient.db"