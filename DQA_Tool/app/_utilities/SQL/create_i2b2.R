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
  start_date::date  AS    EpisodeOfCare_period_start, 
  end_date::date    AS    EpisodeOfCare_period_end
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
  nval_num          AS    procedure_code_coding_code_40617009
FROM 
	i2b2miracum.observation_fact 
WHERE 
	concept_cd LIKE 'FALL:BEATMST'
ORDER BY 
	encounter_num;"


dt.condition_target <- 
"SELECT 
  encounter_num     AS    condition_encounter_identifier_value, 
  concept_cd        AS    condition_code_coding_code,
	modifier_cd       AS    condition_category_encounter_diagnosis
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'ICD%'
ORDER BY
  encounter_num;"


dt.procedure_target <- 
"SELECT 
  encounter_num     AS    procedure_encounter_identifier_value, 
  concept_cd        AS    procedure_code_coding_code,
  start_date::date  AS    procedure_performedDateTime
  
FROM 
  i2b2miracum.observation_fact
WHERE 
  concept_cd LIKE 'OPS%'
ORDER BY
  encounter_num;"


dt.provider_target <- 
"SELECT 
  encounter_num     AS    encounter_identifier_value, 
  tval_char         AS    encounter_serviceProvider_type_Organization_name,
  start_date::date  AS    encounter_period_start, 
  end_date::date    AS    encounter_period_end
FROM 
	i2b2miracum.observation_fact
WHERE 
	concept_cd LIKE 'FACHABT%'
ORDER BY
	encounter_num;"


pl.item02_target <-
"SELECT 
  ob.encounter_num    AS    encounter_identifier_value, 
  ob.patient_num      AS    patient_identifier_value,
  ob.concept_cd       AS    condition_code_coding_code,
  pa.sex_cd           AS    patient_gender
FROM 
  i2b2miracum.observation_fact AS ob
LEFT OUTER JOIN 
  i2b2miracum.patient_dimension AS pa ON ob.patient_num = pa.patient_num
WHERE
  ob.concept_cd ~ 'ICD10:O[0-9]'
ORDER BY
  ob.encounter_num;"


pl.item03_target <- 
"SELECT 
  ob.encounter_num    AS    encounter_identifier_value, 
  ob.patient_num      AS    patient_identifier_value,
  ob.concept_cd       AS    condition_code_coding_code,
  pa.sex_cd           AS    patient_gender
FROM 
  i2b2miracum.observation_fact AS ob
LEFT OUTER JOIN 
  i2b2miracum.patient_dimension AS pa ON ob.patient_num = pa.patient_num
WHERE
  ob.concept_cd ~ 'ICD10:C5[1-8]'
ORDER BY
  ob.encounter_num;"


pl.item04_target <- 
  "SELECT 
  ob.encounter_num    AS    encounter_identifier_value, 
  ob.patient_num      AS    patient_identifier_value,
  ob.concept_cd       AS    condition_code_coding_code,
  pa.sex_cd           AS    patient_gender
FROM 
  i2b2miracum.observation_fact AS ob
LEFT OUTER JOIN 
  i2b2miracum.patient_dimension AS pa ON ob.patient_num = pa.patient_num
WHERE
  ob.concept_cd ~ 'ICD10:C6[0-3]'
ORDER BY
  ob.encounter_num;"


pl.item05_target <-
"SELECT 
  ob.encounter_num    AS    encounter_identifier_value, 
  ob.patient_num      AS    patient_identifier_value,
  ob.concept_cd       AS    condition_code_coding_code,
  pa.sex_cd           AS    patient_gender
FROM 
  i2b2miracum.observation_fact AS ob
LEFT OUTER JOIN 
  i2b2miracum.patient_dimension AS pa ON ob.patient_num = pa.patient_num
WHERE
  ob.concept_cd ~ 'AUFNGR:05'
ORDER BY
  ob.encounter_num;"



vec <- c("dt.patient_target", "dt.encounter_target", "dt.ageindays_target", "dt.ageinyears_target", "dt.admission_target", "dt.hospitalization_target", "dt.discharge_target", "dt.ventilation_target",
         "dt.condition_target", "dt.procedure_target", "dt.provider_target", "pl.item02_target", "pl.item03_target", "pl.item04_target", "pl.item05_target")
string_list <- sapply(vec, function(i){eval(parse(text=i))}, simplify = F, USE.NAMES = T)

jsonlist <- toJSON(string_list, pretty = T, auto_unbox = F)
writeLines(jsonlist, "./DQA_Tool/app/_utilities/SQL/SQL_i2b2.JSON")


# # debugging
# txt <- fromJSON("./sql.JSON")
# txt$"dt_patient.db"