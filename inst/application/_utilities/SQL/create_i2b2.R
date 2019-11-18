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

select_vars <- function(mdr_use) {
  sel_vars <- sapply(mdr.use[,get("source_variable_name")], function(x){paste0(x, "\tAS\t\"", mdr.use[source_variable_name==x,variable_name], "\"")})
  if (length(sel_vars) > 1) {
    sel_vars <- paste(sel_vars, collapse = ",\n")
  }
  return(sel_vars)
}

# read mdr
mdr <- DQAstats::read_mdr(utils = "inst/application/_utilities/")
mdr <- mdr[source_system_name=="i2b2",]


mdr.use <- mdr[key=="dt.patient_target",]

sel_vars <- select_vars(mdr.use)

dt.patient_target <-
  paste0(
  "SELECT
	", sel_vars, "
FROM
	i2b2miracum.", mdr.use[source_variable_name=="patient_num",source_table_name], "
ORDER BY
	patient_num;")



mdr.use <- mdr[key=="dt.birthdate_target",]
sel_vars <- select_vars(mdr.use)

dt.birthdate_target <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	i2b2miracum.", mdr.use[source_variable_name=="birth_date",source_table_name], "
ORDER BY
	patient_num;")


mdr.use <- mdr[key=="dt.gender_target",]
sel_vars <- select_vars(mdr.use)

dt.gender_target <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	i2b2miracum.", mdr.use[source_variable_name=="sex_cd",source_table_name], "
ORDER BY
	patient_num;")


mdr.use <- mdr[key=="dt.zipcode_target",]
sel_vars <- select_vars(mdr.use)

dt.zipcode_target <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	i2b2miracum.", mdr.use[source_variable_name=="zip_cd",source_table_name], "
ORDER BY
	patient_num;")


mdr.use <- mdr[key=="dt.encounter_target",]
sel_vars <- select_vars(mdr.use)

dt.encounter_target <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
ORDER BY
  patient_num;")


# simple cast to date
looplist <- list("dt.ageindays_target" = list(var1 = "encounter_num", var2 = "nval_num"),
                 "dt.encounterstart_target" = list(var1 = "encounter_num", var2 = "start_date"),
                 "dt.encounterend_target" = list(var1 = "encounter_num", var2 = "end_date"))

for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "SELECT
  b.", looplist[[i]]$var1, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var1,variable_name], "\",
  a.", looplist[[i]]$var2, "::date\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var2,variable_name], "\"
FROM
  i2b2miracum.visit_dimension AS b
LEFT OUTER JOIN (
SELECT
  ", looplist[[i]]$var1, ", ", looplist[[i]]$var2, "
FROM
  i2b2miracum.", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], ") AS a ON
  a.", looplist[[i]]$var1, " = b.", looplist[[i]]$var1, "
ORDER BY
  b.", looplist[[i]]$var1, ";")
  )
}


# where clause
looplist <- list("dt.ageindays_target" = list(var1 = "encounter_num", var2 = "nval_num"),
                  "dt.ageinyears_target" = list(var1 = "encounter_num", var2 = "nval_num"),
                  "dt.admission_target" = list(var1 = "encounter_num", var2 = "concept_cd"),
                  "dt.hospitalization_target" = list(var1 = "encounter_num", var2 = "concept_cd"),
                  "dt.discharge_target" = list(var1 = "encounter_num", var2 = "concept_cd"),
                  "dt.ventilation_target" = list(var1 = "encounter_num", var2 = "nval_num"),
                 "dt.condition_target" = list(var1 = "encounter_num", var2 = "concept_cd"),
                 "dt.conditioncategory_target" = list(var1 = "encounter_num", var2 = "modifier_cd"),
                 "dt.procedure_target" = list(var1 = "encounter_num", var2 = "concept_cd"),
                 "dt.provider_target" = list(var1 = "encounter_num", var2 = "tval_char"))


for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "SELECT
  b.", looplist[[i]]$var1, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var1,variable_name], "\",
  a.", looplist[[i]]$var2, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var2,variable_name], "\"
FROM
  i2b2miracum.visit_dimension AS b
LEFT OUTER JOIN (
SELECT
  ", looplist[[i]]$var1, ", ", looplist[[i]]$var2, "
FROM
  i2b2miracum.", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
WHERE
  ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], ") AS a ON
  a.", looplist[[i]]$var1, " = b.", looplist[[i]]$var1, "
ORDER BY
  b.", looplist[[i]]$var1, ";")
  )
}


# cast dates
looplist <- list("dt.proceduredate_target" = list(var1 = "encounter_num", var2 = "start_date"),
                 "dt.providerstart_target" = list(var1 = "encounter_num", var2 = "start_date"),
                 "dt.providerend_target" = list(var1 = "encounter_num", var2 = "end_date"))


for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "SELECT
  b.", looplist[[i]]$var1, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var1,variable_name], "\",
  a.", looplist[[i]]$var2, "::date\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var2,variable_name], "\"
FROM
  i2b2miracum.visit_dimension AS b
LEFT OUTER JOIN (
SELECT
  ", looplist[[i]]$var1, ", ", looplist[[i]]$var2, "
FROM
  i2b2miracum.", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
WHERE
  ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], ") AS a ON
  a.", looplist[[i]]$var1, " = b.", looplist[[i]]$var1, "
ORDER BY
  b.", looplist[[i]]$var1, ";")
  )
}


# # create plausibility statements
# for (i in c("pl.atemp.item01_target", "pl.atemp.item02_target", "pl.atemp.item03_target", "pl.atemp.item04_target")){
#   mdr.use <- mdr[key==i,]
#
#   assign(i,
#          paste0(
#            "SELECT
#   ob.encounter_num    AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
#   ob.patient_num      AS    \"", mdr.use[source_variable_name=="patient_num",variable_name], "\",
#   ob.concept_cd       AS    \"", mdr.use[source_variable_name=="concept_cd",variable_name], "\",
#   pa.sex_cd           AS    \"", mdr.use[source_variable_name=="sex_cd",variable_name], "\"
# FROM
#   i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], " AS ob
# LEFT OUTER JOIN
#   i2b2miracum.patient_dimension AS pa ON ob.patient_num = pa.patient_num
# WHERE
#   ob.", mdr.use[source_variable_name=="sex_cd",sql_where], "
# ORDER BY
#   ob.encounter_num;"))
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
writeLines(jsonlist, "./inst/application/_utilities/SQL/SQL_i2b2.JSON")


# # debugging
# txt <- fromJSON("./sql.JSON")
# txt$"dt_patient.db"
