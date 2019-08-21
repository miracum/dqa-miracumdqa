# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019 Universitätsklinikum Erlangen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

library(jsonlite)
library(data.table)

mdr <- fread("./inst/application/_utilities/MDR/mdr.csv", header = T)
mdr <- mdr[source_system=="omop",]


mdr.use <- mdr[key=="dt.patient_target",]

dt.patient_target <-
  paste0(
    "SELECT
	person_id       AS    \"", mdr.use[source_variable_name=="person_id",variable_name], "\"
FROM
	p21_cdm.", mdr.use[source_variable_name=="person_id",source_table_name], "
ORDER BY
	person_id;")


mdr.use <- mdr[key=="dt.birthdate_target",]

dt.birthdate_target <-
  paste0(
    "SELECT
    person_id       AS    \"", mdr.use[source_variable_name=="person_id",variable_name], "\",
    year_of_birth  AS    \"", mdr.use[source_variable_name=="year_of_birth",variable_name], "\"
FROM
	p21_cdm.", mdr.use[source_variable_name=="year_of_birth",source_table_name], "
ORDER BY
	person_id;")


mdr.use <- mdr[key=="dt.gender_target",]

dt.gender_target <-
  paste0(
    "SELECT
    person_id       AS    \"", mdr.use[source_variable_name=="person_id",variable_name], "\",
    gender_source_value            AS    \"", mdr.use[source_variable_name=="gender_source_value",variable_name], "\"
FROM
	p21_cdm.", mdr.use[source_variable_name=="gender_source_value",source_table_name], "
ORDER BY
	person_id;")


mdr.use <- mdr[key=="dt.zipcode_target",]

dt.zipcode_target <-
  paste0(
    "SELECT
    per.person_id       AS    \"", mdr.use[source_variable_name=="person_id",variable_name], "\",
    loc.zip            AS    \"", mdr.use[source_variable_name=="zip",variable_name], "\"
FROM
	p21_cdm.", mdr.use[source_variable_name=="person_id",source_table_name], " AS per
LEFT OUTER JOIN
  p21_cdm.", mdr.use[source_variable_name=="zip",source_table_name], " AS loc ON
  per.", mdr.use[source_variable_name=="zip",sql_join_on], " = loc.", mdr.use[source_variable_name=="zip",sql_join_on], "
ORDER BY
	person_id;")


mdr.use <- mdr[key=="dt.encounter_target",]

dt.encounter_target <-
  paste0(
    "SELECT
	person_id       AS    \"", mdr.use[source_variable_name=="person_id",variable_name], "\",
  visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="visit_occurrence_id",source_table_name], "
ORDER BY
  person_id;")


mdr.use <- mdr[key=="dt.encounterstart_target",]

dt.encounterstart_target <-
  paste0(
    "SELECT
  visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  visit_start_date  AS    \"", mdr.use[source_variable_name=="visit_start_date",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="visit_start_date",source_table_name], "
ORDER BY
  visit_occurrence_id;")


mdr.use <- mdr[key=="dt.encounterend_target",]

dt.encounterend_target <-
  paste0(
    "SELECT
  visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  visit_end_date  AS    \"", mdr.use[source_variable_name=="visit_end_date",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="visit_end_date",source_table_name], "
ORDER BY
  visit_occurrence_id;")


mdr.use <- mdr[key=="dt.ageindays_target",]

dt.ageindays_target <-
  paste0(
    "SELECT
  visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  observation_source_value::numeric          AS    \"", mdr.use[source_variable_name=="observation_source_value",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="observation_source_value",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="observation_source_value",sql_where], "
ORDER BY
  visit_occurrence_id;")


mdr.use <- mdr[key=="dt.ageinyears_target",]

dt.ageinyears_target <-
  paste0(
    "SELECT
  visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  observation_source_value::numeric          AS    \"", mdr.use[source_variable_name=="observation_source_value",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="observation_source_value",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="observation_source_value",sql_where], "
ORDER BY
  visit_occurrence_id;")


mdr.use <- mdr[key=="dt.admission_target",]

dt.admission_target <-
  paste0(
    "SELECT
	visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  observation_source_value        AS    \"", mdr.use[source_variable_name=="observation_source_value",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="observation_source_value",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="observation_source_value",sql_where], "
ORDER BY
  visit_occurrence_id;")


mdr.use <- mdr[key=="dt.hospitalization_target",]

dt.hospitalization_target <-
  paste0(
    "SELECT
	visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  observation_source_value        AS    \"", mdr.use[source_variable_name=="observation_source_value",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="observation_source_value",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="observation_source_value",sql_where], "
ORDER BY
  visit_occurrence_id;")


mdr.use <- mdr[key=="dt.discharge_target",]

dt.discharge_target <-
  paste0(
    "SELECT
	visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  observation_source_value        AS    \"", mdr.use[source_variable_name=="observation_source_value",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="observation_source_value",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="observation_source_value",sql_where], "
ORDER BY
  visit_occurrence_id;")


mdr.use <- mdr[key=="dt.ventilation_target",]

dt.ventilation_target <-
  paste0(
    "SELECT
  visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  observation_source_value::numeric          AS    \"", mdr.use[source_variable_name=="observation_source_value",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="observation_source_value",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="observation_source_value",sql_where], "
ORDER BY
	visit_occurrence_id;")


mdr.use <- mdr[key=="dt.condition_target",]

dt.condition_target <-
  paste0(
    "SELECT
	visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  condition_source_value        AS    \"", mdr.use[source_variable_name=="condition_source_value",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="condition_source_value",source_table_name], "
ORDER BY
  visit_occurrence_id;")


mdr.use <- mdr[key=="dt.conditioncategory_target",]

dt.conditioncategory_target <-
  paste0(
    "SELECT
	visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
	condition_type_concept_id       AS    \"", mdr.use[source_variable_name=="condition_type_concept_id",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="condition_type_concept_id",source_table_name], "
ORDER BY
  visit_occurrence_id;")


mdr.use <- mdr[key=="dt.procedure_target",]

dt.procedure_target <-
  paste0(
    "SELECT
	visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  procedure_source_value        AS    \"", mdr.use[source_variable_name=="procedure_source_value",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="procedure_source_value",source_table_name], "
ORDER BY
  visit_occurrence_id;")


mdr.use <- mdr[key=="dt.proceduredate_target",]

dt.proceduredate_target <-
  paste0(
    "SELECT
	visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  procedure_date  AS    \"", mdr.use[source_variable_name=="procedure_date",variable_name], "\"
FROM
  p21_cdm.", mdr.use[source_variable_name=="procedure_date",source_table_name], "
ORDER BY
  visit_occurrence_id;")


mdr.use <- mdr[key=="dt.provider_target",]

dt.provider_target <-
  paste0(
    "SELECT
	visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  care_site_id         AS    \"", mdr.use[source_variable_name=="care_site_id",variable_name], "\"
FROM
	p21_cdm.", mdr.use[source_variable_name=="care_site_id",source_table_name], "
ORDER BY
	visit_occurrence_id;")


mdr.use <- mdr[key=="dt.providerstart_target",]

dt.providerstart_target <-
  paste0(
    "SELECT
	visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  visit_start_date  AS    \"", mdr.use[source_variable_name=="visit_start_date",variable_name], "\"
FROM
	p21_cdm.", mdr.use[source_variable_name=="visit_start_date",source_table_name], "
ORDER BY
	visit_occurrence_id;")


mdr.use <- mdr[key=="dt.providerend_target",]

dt.providerend_target <-
  paste0(
    "SELECT
	visit_occurrence_id     AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
  visit_end_date    AS    \"", mdr.use[source_variable_name=="visit_end_date",variable_name], "\"
FROM
	p21_cdm.", mdr.use[source_variable_name=="visit_end_date",source_table_name], "
ORDER BY
	visit_occurrence_id;")


# # create plausibility statements
# for (i in c("pl.atemp.item01_target", "pl.atemp.item02_target", "pl.atemp.item03_target", "pl.atemp.item04_target")){
#   mdr.use <- mdr[key==i,]
#
#   assign(i,
#          paste0(
#            "SELECT
#   ob.visit_occurrence_id    AS    \"", mdr.use[source_variable_name=="visit_occurrence_id",variable_name], "\",
#   ob.person_id      AS    \"", mdr.use[source_variable_name=="person_id",variable_name], "\",
#   ob.concept_cd       AS    \"", mdr.use[source_variable_name=="concept_cd",variable_name], "\",
#   pa.gender_source_value           AS    \"", mdr.use[source_variable_name=="gender_source_value",variable_name], "\"
# FROM
#   p21_cdm.", mdr.use[source_variable_name=="visit_occurrence_id",source_table_name], " AS ob
# LEFT OUTER JOIN
#   p21_cdm.patient_dimension AS pa ON ob.person_id = pa.person_id
# WHERE
#   ob.", mdr.use[source_variable_name=="gender_source_value",sql_where], "
# ORDER BY
#   ob.visit_occurrence_id;"))
# }



vec <- c("dt.patient_target", "dt.gender_target", "dt.zipcode_target", "dt.birthdate_target",
         "dt.encounter_target", "dt.encounterstart_target", "dt.encounterend_target",
         "dt.ageindays_target", "dt.ageinyears_target", "dt.admission_target", "dt.hospitalization_target",
         "dt.discharge_target", "dt.ventilation_target",
         "dt.condition_target", "dt.conditioncategory_target",
         "dt.procedure_target", "dt.proceduredate_target",
         "dt.provider_target", "dt.providerstart_target", "dt.providerend_target")
         #"pl.atemp.item01_target", "pl.atemp.item02_target", "pl.atemp.item03_target", "pl.atemp.item04_target")
string_list <- sapply(vec, function(i){eval(parse(text=i))}, simplify = F, USE.NAMES = T)

jsonlist <- toJSON(string_list, pretty = T, auto_unbox = F)
writeLines(jsonlist, "./inst/application/_utilities/SQL/SQL_omop.JSON")


# # debugging
# txt <- fromJSON("./sql.JSON")
# txt$"dt_patient.db"
