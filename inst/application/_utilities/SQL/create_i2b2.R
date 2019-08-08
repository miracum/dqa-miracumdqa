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
mdr <- mdr[source_system=="i2b2",]


mdr.use <- mdr[key=="dt.patient_target",]

dt.patient_target <-
  paste0(
    "SELECT
	patient_num       AS    \"", mdr.use[source_variable_name=="patient_num",variable_name], "\"
FROM
	i2b2miracum.", mdr.use[source_variable_name=="patient_num",source_table_name], "
ORDER BY
	patient_num;")


mdr.use <- mdr[key=="dt.birthdate_target",]

dt.birthdate_target <-
  paste0(
    "SELECT
    patient_num       AS    \"", mdr.use[source_variable_name=="patient_num",variable_name], "\",
    birth_date::date  AS    \"", mdr.use[source_variable_name=="birth_date",variable_name], "\"
FROM
	i2b2miracum.", mdr.use[source_variable_name=="patient_num",source_table_name], "
ORDER BY
	patient_num;")


mdr.use <- mdr[key=="dt.gender_target",]

dt.gender_target <-
  paste0(
    "SELECT
    patient_num       AS    \"", mdr.use[source_variable_name=="patient_num",variable_name], "\",
    sex_cd            AS    \"", mdr.use[source_variable_name=="sex_cd",variable_name], "\"
FROM
	i2b2miracum.", mdr.use[source_variable_name=="patient_num",source_table_name], "
ORDER BY
	patient_num;")


mdr.use <- mdr[key=="dt.zipcode_target",]

dt.zipcode_target <-
  paste0(
    "SELECT
    patient_num       AS    \"", mdr.use[source_variable_name=="patient_num",variable_name], "\",
    zip_cd            AS    \"", mdr.use[source_variable_name=="zip_cd",variable_name], "\"
FROM
	i2b2miracum.", mdr.use[source_variable_name=="patient_num",source_table_name], "
ORDER BY
	patient_num;")


mdr.use <- mdr[key=="dt.encounter_target",]

dt.encounter_target <-
  paste0(
    "SELECT
	patient_num       AS    \"", mdr.use[source_variable_name=="patient_num",variable_name], "\",
  encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="patient_num",source_table_name], "
ORDER BY
  patient_num;")


mdr.use <- mdr[key=="dt.encounterstart_target",]

dt.encounterstart_target <-
  paste0(
    "SELECT
  encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  start_date::date  AS    \"", mdr.use[source_variable_name=="start_date",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
ORDER BY
  encounter_num;")


mdr.use <- mdr[key=="dt.encounterend_target",]

dt.encounterend_target <-
  paste0(
    "SELECT
  encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  end_date::date  AS    \"", mdr.use[source_variable_name=="end_date",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
ORDER BY
  encounter_num;")


mdr.use <- mdr[key=="dt.ageindays_target",]

dt.ageindays_target <-
  paste0(
    "SELECT
  encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  nval_num          AS    \"", mdr.use[source_variable_name=="nval_num",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
GROUP BY
	encounter_num, patient_num, concept_cd, nval_num
ORDER BY
  encounter_num;")


mdr.use <- mdr[key=="dt.ageinyears_target",]

dt.ageinyears_target <-
  paste0(
    "SELECT
  encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  nval_num          AS    \"", mdr.use[source_variable_name=="nval_num",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
GROUP BY
	encounter_num, patient_num, concept_cd, nval_num
ORDER BY
  encounter_num;")


mdr.use <- mdr[key=="dt.admission_target",]

dt.admission_target <-
  paste0(
    "SELECT
	encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  concept_cd        AS    \"", mdr.use[source_variable_name=="concept_cd",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
ORDER BY
  encounter_num;")


mdr.use <- mdr[key=="dt.hospitalization_target",]

dt.hospitalization_target <-
  paste0(
    "SELECT
	encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  concept_cd        AS    \"", mdr.use[source_variable_name=="concept_cd",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
ORDER BY
  encounter_num;")


mdr.use <- mdr[key=="dt.discharge_target",]

dt.discharge_target <-
  paste0(
    "SELECT
	encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  concept_cd        AS    \"", mdr.use[source_variable_name=="concept_cd",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
ORDER BY
  encounter_num;")


mdr.use <- mdr[key=="dt.ventilation_target",]

dt.ventilation_target <-
  paste0(
    "SELECT
  encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  nval_num          AS    \"", mdr.use[source_variable_name=="nval_num",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
ORDER BY
	encounter_num;")


mdr.use <- mdr[key=="dt.condition_target",]

dt.condition_target <-
  paste0(
    "SELECT
	encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  concept_cd        AS    \"", mdr.use[source_variable_name=="concept_cd",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
ORDER BY
  encounter_num;")


mdr.use <- mdr[key=="dt.conditioncategory_target",]

dt.conditioncategory_target <-
  paste0(
    "SELECT
	encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
	modifier_cd       AS    \"", mdr.use[source_variable_name=="modifier_cd",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
ORDER BY
  encounter_num;")


mdr.use <- mdr[key=="dt.procedure_target",]

dt.procedure_target <-
  paste0(
    "SELECT
	encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  concept_cd        AS    \"", mdr.use[source_variable_name=="concept_cd",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
ORDER BY
  encounter_num;")


mdr.use <- mdr[key=="dt.proceduredate_target",]

dt.proceduredate_target <-
  paste0(
    "SELECT
	encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  start_date::date  AS    \"", mdr.use[source_variable_name=="start_date",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
ORDER BY
  encounter_num;")


mdr.use <- mdr[key=="dt.provider_target",]

dt.provider_target <-
  paste0(
    "SELECT
	encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  tval_char         AS    \"", mdr.use[source_variable_name=="tval_char",variable_name], "\"
FROM
	i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
ORDER BY
	encounter_num;")


mdr.use <- mdr[key=="dt.providerstart_target",]

dt.providerstart_target <-
  paste0(
    "SELECT
	encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  start_date::date  AS    \"", mdr.use[source_variable_name=="start_date",variable_name], "\"
FROM
	i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
ORDER BY
	encounter_num;")


mdr.use <- mdr[key=="dt.providerend_target",]

dt.providerend_target <-
  paste0(
    "SELECT
	encounter_num     AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  end_date::date    AS    \"", mdr.use[source_variable_name=="end_date",variable_name], "\"
FROM
	i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="encounter_num",sql_where], "
ORDER BY
	encounter_num;")


# create plausibility statements
for (i in c("pl.atemp.item01_target", "pl.atemp.item02_target", "pl.atemp.item03_target", "pl.atemp.item04_target")){
  mdr.use <- mdr[key==i,]

  assign(i,
         paste0(
           "SELECT
  ob.encounter_num    AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
  ob.patient_num      AS    \"", mdr.use[source_variable_name=="patient_num",variable_name], "\",
  ob.concept_cd       AS    \"", mdr.use[source_variable_name=="concept_cd",variable_name], "\",
  pa.sex_cd           AS    \"", mdr.use[source_variable_name=="sex_cd",variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], " AS ob
LEFT OUTER JOIN
  i2b2miracum.patient_dimension AS pa ON ob.patient_num = pa.patient_num
WHERE
  ob.", mdr.use[source_variable_name=="sex_cd",sql_where], "
ORDER BY
  ob.encounter_num;"))
}



vec <- c("dt.patient_target", "dt.gender_target", "dt.zipcode_target", "dt.birthdate_target",
         "dt.encounter_target", "dt.encounterstart_target", "dt.encounterend_target",
         "dt.ageindays_target", "dt.ageinyears_target", "dt.admission_target", "dt.hospitalization_target",
         "dt.discharge_target", "dt.ventilation_target",
         "dt.condition_target", "dt.conditioncategory_target",
         "dt.procedure_target", "dt.proceduredate_target",
         "dt.provider_target", "dt.providerstart_target", "dt.providerend_target",
         "pl.atemp.item01_target", "pl.atemp.item02_target", "pl.atemp.item03_target", "pl.atemp.item04_target")
string_list <- sapply(vec, function(i){eval(parse(text=i))}, simplify = F, USE.NAMES = T)

jsonlist <- toJSON(string_list, pretty = T, auto_unbox = F)
writeLines(jsonlist, "./inst/application/_utilities/SQL/SQL_i2b2.JSON")


# # debugging
# txt <- fromJSON("./sql.JSON")
# txt$"dt_patient.db"
