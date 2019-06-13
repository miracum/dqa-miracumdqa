# (c) 2019 Lorenz Kapsner

library(jsonlite)

# concept_id=8507: MALE
# concept_id=8532: FEMALE
# concept_id=8551: UNKNOWN
dt_patient.db <- 
  "SELECT
  per.person_id       AS    patient_id, 
  per.year_of_birth   AS    birth_date,
  per.month_of_birth  AS    birth_month,
  con.concept_code    AS    gender, 
  loc.zip             AS    zip_code
FROM
	p21_cdm.person AS per
LEFT OUTER JOIN 
	p21_cdm.location AS loc ON 
	per.location_id = loc.location_id
LEFT OUTER JOIN 
	p21_cdm.concept AS con ON 
	per.gender_concept_id = con.concept_id
ORDER BY 
	per.person_id;"


dt_visit.db <- 
  "SELECT
  person_id               AS    patient_id, 
  visit_occurrence_id     AS    encounter_id, 
  visit_start_date::DATE  AS    encounter_start_date, 
  visit_end_date::DATE    AS    encounter_end_date
FROM 
	p21_cdm.visit_occurrence
ORDER BY 
	person_id;"


# concept_id Age == 4265453
# unit day == 8512
dt_aitaa.db <- 
  "SELECT 
  obs.visit_occurrence_id AS    encounter_id, 
  obs.value_as_number     AS    age
FROM 
  p21_cdm.observation AS obs
WHERE 
  obs.observation_concept_id = 4265453 AND
  obs.unit_concept_id = 8512
ORDER BY
  obs.visit_occurrence_id;"


# concept_id Age == 4265453
# unit year == 9448
dt_aijaa.db <- 
  "SELECT 
  obs.visit_occurrence_id AS    encounter_id, 
  obs.value_as_number     AS    age
FROM 
  p21_cdm.observation AS obs
WHERE 
  obs.observation_concept_id = 4265453 AND
  obs.unit_concept_id = 9448
ORDER BY
  obs.visit_occurrence_id;"


## Mapping lt. ETL-Job (Stand 06.03.2019)
# Aufnahmeanlass: observation_type_concept_id = 43542355 = Referral Record
# N= 4079617: Emergency hospital admission
# V= 4164916: Hospital admission, transfer from other hospital or health care facility
# E= 4138807: Admission by physician
# Z= 4123917: Admission by dental surgeon
# A= 4164916: Hospital admission, transfer from other hospital or health care facility
# G= 4216316: Birth
# R= 4146925: Discharge from rehabilitation service
# B= 4194310: Chaperone present
dt_aufnan.db <- 
  "SELECT 
  obs.visit_occurrence_id AS    encounter_id, 
  obs.value_as_string     AS    admission_occasion
FROM 
  p21_cdm.observation AS obs
WHERE 
  obs.observation_concept_id IN (4079617, 4164916, 4138807, 4123917, 4164916, 4216316, 4146925, 4194310) AND 
  obs.observation_type_concept_id = 43542355
ORDER BY
  obs.visit_occurrence_id;"


## Mapping lt. ETL-Job (Stand 06.03.2019)
# Aufnahmegrund: observation_type_concept_id = 43542355 = Referral Record
# 01xx: 4214577: Inpatient care
# 02xx: 4010105: Hospital admission, elective, with complete pre-admission work-up
# 03xx: 4123929: Admission to day ward
# 04xx: 4235698: Pre-admission assessment
# 05xx: 4214577: Inpatient care
# 06xx: 4216316: Birth
# 07xx: 4213258: Hospital re-admission
# 08xx: 4180080: Hospital admission, donor for transplant organ


dt_aufngr.db <- 
  "SELECT 
  obs.visit_occurrence_id AS    encounter_id, 
  obs.value_as_string     AS    admission_reason
FROM 
  p21_cdm.observation AS obs
WHERE 
  obs.observation_concept_id IN (4214577, 4010105, 4123929, 4235698, 4214577, 4216316, 4213258, 4180080) AND 
  obs.observation_type_concept_id = 43542355
ORDER BY
  obs.visit_occurrence_id;"


## Mapping lt. ETL-Job (Stand 06.03.2019)
# Entlassgrund: observation_type_concept_id = 38000280 = Observation recorded from EHR
# 01x: 4082735: Treatment completed
# 02x: 4082735: Treatment completed
# 03x: 4203130: Discharge from hospital
# 04x: 4021968: Patient self-discharge against medical advice
# 14x: 4203130: Discharge from hospital
# 15x: 4021968: Patient self-discharge against medical advice
# 21x: 4203130: Discharge from hospital
# 069: 4147710: Referral to hospital
# 079: 4216643: Patient died
# 089: 4147710: Referral to hospital
# 099: 4139566: Referral to rehabilitation service
# 109: 4143443: Discharge to nursing home
# 119: 4127600: Referral to hospice
# 129: 45878214: Internal facility referral or transfer
# 139: 4084686: Referral to psychiatry service
# 169: 4203130: Discharge from hospital
# 179: 45878214: Internal facility referral or transfer
# 189: 4213258: Hospital re-admission
# 199: 4203130: Discharge from hospital
# 209: 4203130: Discharge from hospital
# 229: 4084500: Discharged from inpatient care
# 239: 4203130: Discharge from hospital
# 249: 4203130: Discharge from hospital

dt_entlgr.db <- 
  "SELECT 
  obs.visit_occurrence_id AS    encounter_id, 
  obs.value_as_string     AS    discharge_reason
FROM 
  p21_cdm.observation AS obs
WHERE 
  obs.observation_concept_id IN (4082735, 4203130, 4021968, 4147710, 4216643, 4139566, 4143443, 4127600, 45878214, 4084686, 4213258, 4084500) AND
  obs.observation_type_concept_id = 38000280
ORDER BY
  obs.visit_occurrence_id;"


dt_beatmst.db <- 
  "SELECT 
  obs.visit_occurrence_id AS    encounter_id, 
  obs.value_as_number     AS    ventilation_hours
FROM 
  p21_cdm.observation AS obs
WHERE 
  obs.observation_concept_id = 4108449
ORDER BY
  obs.visit_occurrence_id;"



# 44786627: Primary Condition
# 44786629: Secondary Condition
# 0: No matching concept
dt_icd.db <- 
  "SELECT
  cond.visit_occurrence_id	      AS 		encounter_id,
  cond.condition_concept_id	      AS 		snomed,
  icd.source_code			            AS		icd_code,
  cond.condition_type_concept_id  AS    diagnosis_type
FROM
(SELECT 
  DISTINCT
  source_code,
  target_concept_id
FROM
  p21_cdm.source_to_concept_map
WHERE
  source_vocabulary_id='ICD10GM') AS icd
JOIN 
  p21_cdm.condition_occurrence AS cond ON
  cond.condition_concept_id = icd.target_concept_id
WHERE
  cond.condition_type_concept_id IN (44786627, 44786629)
  AND cond.condition_type_concept_id != 0
ORDER BY 
  cond.visit_occurrence_id;"


dt_ops.db <- 
  "SELECT 
  visit_occurrence_id		  AS		encounter_id,
  procedure_concept_id		AS		snomed,
  procedure_source_value	AS		ops_code,
  procedure_date::date 		AS 		ops_date
FROM
  p21_cdm.procedure_occurrence
ORDER BY 
  visit_occurrence_id;"


dt_fab.db <- 
  "SELECT 
  visit_occurrence_id		AS 		encounter_id,
  care_site_id				  AS		department
FROM 
  p21_cdm.visit_occurrence;"


dt_pl_c5x.db <- 
  "SELECT 
  cond.visit_occurrence_id		AS 		encounter_id,
  cond.person_id				      AS 		patient_id,
  icd.source_code				      AS 		icd_code,
  con.concept_code  			    AS	  gender
FROM
(SELECT
  DISTINCT
  source_code,
  target_concept_id,
  regexp_matches(source_code, 'C5[1-8]', 'g')
FROM
  p21_cdm.source_to_concept_map
WHERE
  source_vocabulary_id='ICD10GM'
ORDER BY 
  source_code) AS icd
JOIN 
  p21_cdm.condition_occurrence AS cond ON
  cond.condition_concept_id = icd.target_concept_id
LEFT OUTER JOIN 
  p21_cdm.person AS per ON 
  cond.person_id = per.person_id
LEFT OUTER JOIN 
  p21_cdm.concept AS con ON 
  per.gender_concept_id = con.concept_id
ORDER BY 
  cond.visit_occurrence_id;"


dt_pl_c6x.db <- 
  "SELECT 
  cond.visit_occurrence_id		AS 		encounter_id,
  cond.person_id				      AS 		patient_id,
  icd.source_code				      AS 		icd_code,
  con.concept_code  			    AS	  gender
FROM
(SELECT
  DISTINCT
  source_code,
  target_concept_id,
  regexp_matches(source_code, 'C6[0-3]', 'g')
FROM
  p21_cdm.source_to_concept_map
WHERE
  source_vocabulary_id='ICD10GM'
ORDER BY 
  source_code) AS icd
JOIN 
  p21_cdm.condition_occurrence AS cond ON
  cond.condition_concept_id = icd.target_concept_id
LEFT OUTER JOIN 
  p21_cdm.person AS per ON 
  cond.person_id = per.person_id
LEFT OUTER JOIN 
  p21_cdm.concept AS con ON 
  per.gender_concept_id = con.concept_id
ORDER BY 
  cond.visit_occurrence_id;"

## Mapping lt. ETL-Job (Stand 06.03.2019)
# Aufnahmegrund: observation_type_concept_id = 43542355 = Referral Record
# 05xx: 4214577: Inpatient care
dt_pl_05xx.db <-
  "SELECT 
  obs.visit_occurrence_id		  AS 		  encounter_id,
  obs.person_id					      AS 		  patient_id,
  obs.value_as_string     		AS    	admission_reason,
  obs.observation_concept_id	AS 		  snomed,
  con.concept_code  			    AS	    gender
FROM 
  p21_cdm.observation AS obs
LEFT OUTER JOIN 
  p21_cdm.person AS per ON 
  obs.person_id = per.person_id
LEFT OUTER JOIN 
  p21_cdm.concept AS con ON 
  per.gender_concept_id = con.concept_id
WHERE 
  obs.observation_concept_id = 4214577 AND
  obs.observation_type_concept_id = 43542355
ORDER BY
  obs.visit_occurrence_id;"


dt_pl_o0099.db <-
  "SELECT 
  cond.visit_occurrence_id		AS 		encounter_id,
  cond.person_id				      AS 		patient_id,
  icd.source_code				      AS 		icd_code,
  con.concept_code  			    AS	  gender
FROM
(SELECT
  DISTINCT
  source_code,
  target_concept_id,
  regexp_matches(source_code, 'O[0-9]', 'g')
FROM
  p21_cdm.source_to_concept_map
WHERE
  source_vocabulary_id='ICD10GM'
ORDER BY 
  source_code) AS icd
JOIN 
  p21_cdm.condition_occurrence AS cond ON
  cond.condition_concept_id = icd.target_concept_id
LEFT OUTER JOIN 
  p21_cdm.person AS per ON 
  cond.person_id = per.person_id
LEFT OUTER JOIN 
  p21_cdm.concept AS con ON 
  per.gender_concept_id = con.concept_id
ORDER BY 
  cond.visit_occurrence_id;"



string_list <- list()


for (i in c("dt_patient.db", "dt_visit.db", "dt_aitaa.db", "dt_aijaa.db", "dt_aufnan.db", "dt_aufngr.db", "dt_entlgr.db", "dt_beatmst.db",
            "dt_icd.db", "dt_ops.db", "dt_fab.db", "dt_pl_c5x.db", "dt_pl_c6x.db", "dt_pl_05xx.db", "dt_pl_o0099.db")){
  print(i)
  string_list[[i]] <- eval(parse(text=i))
}

jsonlist <- toJSON(string_list, pretty = T, auto_unbox = F)
writeLines(jsonlist, "./app/DQA_Tool/_utilities/SQL/SQL_omop.JSON")


# # debugging
# txt <- fromJSON("./sql.JSON")
# txt$"dt_patient.db"