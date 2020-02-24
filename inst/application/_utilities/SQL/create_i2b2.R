# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2020 Universitätsklinikum Erlangen
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
mdr <- DQAstats::read_mdr(utils = "inst/application/_utilities/", mdr_filename = "mdr.csv")
mdr <- mdr[source_system_name=="i2b2",]


mdr.use <- mdr[key=="dt.patient",]

sel_vars <- select_vars(mdr.use)

dt.patient <-
  paste0(
  "SELECT
	", sel_vars, "
FROM
	i2b2miracum.", mdr.use[source_variable_name=="patient_num",source_table_name], "
ORDER BY
	patient_num;")



mdr.use <- mdr[key=="dt.birthdate",]
sel_vars <- select_vars(mdr.use)

dt.birthdate <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	i2b2miracum.", mdr.use[source_variable_name=="birth_date",source_table_name], "
ORDER BY
	patient_num;")


mdr.use <- mdr[key=="dt.gender",]
sel_vars <- select_vars(mdr.use)

dt.gender <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	i2b2miracum.", mdr.use[source_variable_name=="sex_cd",source_table_name], "
ORDER BY
	patient_num;")


mdr.use <- mdr[key=="dt.zipcode",]
sel_vars <- select_vars(mdr.use)

dt.zipcode <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	i2b2miracum.", mdr.use[source_variable_name=="zip_cd",source_table_name], "
ORDER BY
	patient_num;")


mdr.use <- mdr[key=="dt.encounter",]
sel_vars <- select_vars(mdr.use)

dt.encounter <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
  i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
ORDER BY
  patient_num;")


# simple cast to date
looplist <- list("dt.encounterstart" = list(var1 = "encounter_num", var2 = "start_date"),
                 "dt.encounterend" = list(var1 = "encounter_num", var2 = "end_date"))

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

# where clause without left outer join on case-id
looplist <- list("dt.procedure_medication" = list(var1 = "encounter_num", var2 = "concept_cd"),
                 "dt.procedure" = list(var1 = "encounter_num", var2 = "concept_cd"),
                 "dt.provider" = list(var1 = "encounter_num", var2 = "tval_char"))


for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "
SELECT
  ", looplist[[i]]$var1, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var1,variable_name], "\",
  ", looplist[[i]]$var2, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var2,variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
WHERE
  ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], "
ORDER BY
  ", looplist[[i]]$var1, ";")
  )
}


# where clause with left outer join on case-id
looplist <- list("dt.ageindays" = list(var1 = "encounter_num", var2 = "nval_num"),
                  "dt.ageinyears" = list(var1 = "encounter_num", var2 = "nval_num"),
                  "dt.admission" = list(var1 = "encounter_num", var2 = "tval_char"),
                  "dt.hospitalization" = list(var1 = "encounter_num", var2 = "tval_char"),
                  "dt.discharge" = list(var1 = "encounter_num", var2 = "tval_char"),
                  "dt.ventilation" = list(var1 = "encounter_num", var2 = "nval_num"),
                 "dt.condition" = list(var1 = "encounter_num", var2 = "concept_cd"),
                 "dt.conditioncategory" = list(var1 = "encounter_num", var2 = "modifier_cd"))


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
looplist <- list("dt.proceduredate" = list(var1 = "encounter_num", var2 = "start_date"),
                 "dt.providerstart" = list(var1 = "encounter_num", var2 = "start_date"),
                 "dt.providerend" = list(var1 = "encounter_num", var2 = "end_date"))


for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "SELECT
  ", looplist[[i]]$var1, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var1,variable_name], "\",
  ", looplist[[i]]$var2, "::date\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var2,variable_name], "\"
FROM
  i2b2miracum.", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
WHERE
  ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], "
ORDER BY
  ", looplist[[i]]$var1, ";")
  )
}


# # create plausibility statements
# for (i in c("pl.atemp.item01", "pl.atemp.item02", "pl.atemp.item03", "pl.atemp.item04")){
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
#

mdr.use <- mdr[key=="dt.laboratory",]

sel_vars <- select_vars(mdr.use)

dt.laboratory <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	i2b2miracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="concept_cd",sql_where], ";")



vec <- c("dt.patient", "dt.gender", "dt.zipcode", "dt.birthdate",
         "dt.encounter", "dt.encounterstart", "dt.encounterend",
         "dt.ageindays", "dt.ageinyears", "dt.admission", "dt.hospitalization",
         "dt.discharge", "dt.ventilation",
         "dt.condition", "dt.conditioncategory",
         "dt.procedure", "dt.proceduredate",
         "dt.procedure_medication", "dt.laboratory",
         "dt.provider", "dt.providerstart", "dt.providerend")
         #"pl.atemp.item01", "pl.atemp.item02", "pl.atemp.item03", "pl.atemp.item04")
string_list <- sapply(vec, function(i){eval(parse(text=i))}, simplify = F, USE.NAMES = T)

jsonlist <- toJSON(string_list, pretty = T, auto_unbox = F)
writeLines(jsonlist, "./inst/application/_utilities/SQL/SQL_i2b2.JSON")


# # debugging
# txt <- fromJSON("./sql.JSON")
# txt$"dt_patient.db"
