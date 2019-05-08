# by Lorenz Kapsner

library(jsonlite)


dt.patient_target <- 
"SELECT
	patient_num       AS    patient_identifier_value, 
  birth_date::date  AS    patient_birthDate, 
  sex_cd            AS    patient_gender, 
  zip_cd            AS    patient_address_postalCode
FROM
	i2b2miracum.patient_dimension
ORDER BY 
	patient_num;"


dt.encounter_target <- 
"SELECT
	patient_num       AS    encounter_subject_patient_identifier_value,
  encounter_num     AS    encounter_identifier_value, 
  start_date::date  AS    encounter_period_start, 
  end_date::date    AS    encounter_period_end
FROM
  i2b2miracum.visit_dimension
ORDER BY 
  patient_num;"


dt.ageindays_target <- 
"SELECT 
  encounter_num     AS    encounter_identifier_value, 
  nval_num          AS    encounter_subject_patient_age_days
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'FALL:AITAA'
GROUP BY
	encounter_num, patient_num, concept_cd, nval_num
ORDER BY
  encounter_num;"


dt.ageinyears_target <- 
"SELECT 
  encounter_num     AS    encounter_identifier_value, 
  nval_num          AS    encounter_subject_patient_age_days
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'FALL:AIJAA'
GROUP BY
	encounter_num, patient_num, concept_cd, nval_num
ORDER BY
  encounter_num;"


dt.admission_target <- 
"SELECT
	encounter_num     AS    encounter_identifier_value, 
  concept_cd        AS    encounter_hospitalization_admitSource
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'AUFNAN%'
ORDER BY 
  encounter_num;"


dt.hospitalization_target <- 
"SELECT 
  encounter_num     AS    encounter_identifier_value, 
  concept_cd        AS    encounter_hospitalization_class
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'AUFNGR%'
ORDER BY 
  encounter_num;"


dt.discharge_target <- 
"SELECT 
  encounter_num     AS    encounter_identifier_value, 
  concept_cd        AS    encounter_hospitalization_dischargeDisposition
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'ENTLGR%'
ORDER BY 
  encounter_num;"


dt.ventilation_target <- 
"SELECT 
  encounter_num     AS    procedure_encounter_identifier_value, 
  nval_num          AS    procedure_code_40617009
FROM 
	i2b2miracum.observation_fact 
WHERE 
	concept_cd LIKE 'FALL:BEATMST'
ORDER BY 
	encounter_num;"


dt_icd.db <- 
  "SELECT 
  encounter_num     AS    encounter_identifier_value, 
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


for (i in c("dt.patient_target", "dt.encounter_target", "dt.ageindays_target", "dt.ageinyears_target", "dt.admission_target", "dt.hospitalization_target", "dt.discharge_target", "dt.ventilation_target",
            "dt_icd.db", "dt_ops.db", "dt_fab.db", "dt_pl_c5x.db", "dt_pl_c6x.db", "dt_pl_05xx.db", "dt_pl_o0099.db")){
  print(i)
  string_list[[i]] <- eval(parse(text=i))
}

jsonlist <- toJSON(string_list, pretty = T, auto_unbox = F)
writeLines(jsonlist, "./DQA_Tool/app/_utilities/SQL/SQL_i2b2.JSON")


# # debugging
# txt <- fromJSON("./sql.JSON")
# txt$"dt_patient.db"