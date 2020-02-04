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
  sel_vars <- sapply(mdr.use[,get("source_variable_name")], function(x){paste0("\"", x, "\"\tAS\t\"", mdr.use[source_variable_name==x,variable_name], "\"")})
  if (length(sel_vars) > 1) {
    sel_vars <- paste(sel_vars, collapse = ",\n")
  }
  return(sel_vars)
}

# read mdr
mdr <- DQAstats::read_mdr(utils_path = "inst/application/_utilities/", mdr_filename = "mdr.csv")
mdr <- mdr[source_system_name=="p21staging",]


mdr.use <- mdr[key=="dt.patient",]

sel_vars <- select_vars(mdr.use)

dt.patient <-
  paste0(
  "SELECT
	", sel_vars, "
FROM
	p21.", mdr.use[source_variable_name=="Patientennummer",source_table_name], "
ORDER BY
	\"Patientennummer\";")



mdr.use <- mdr[key=="dt.birthdate",]
sel_vars <- select_vars(mdr.use)

dt.birthdate <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	p21.", mdr.use[source_variable_name=="Geburtsjahr",source_table_name], "
ORDER BY
	\"Patientennummer\";")


mdr.use <- mdr[key=="dt.gender",]
sel_vars <- select_vars(mdr.use)

dt.gender <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	p21.", mdr.use[source_variable_name=="Geschlecht",source_table_name], "
ORDER BY
	\"Patientennummer\";")


mdr.use <- mdr[key=="dt.zipcode",]
sel_vars <- select_vars(mdr.use)

dt.zipcode <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	p21.", mdr.use[source_variable_name=="PLZ",source_table_name], "
ORDER BY
	\"Patientennummer\";")


mdr.use <- mdr[key=="dt.encounter",]
sel_vars <- select_vars(mdr.use)

dt.encounter <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
  p21.", mdr.use[source_variable_name=="KH-internes-Kennzeichen",source_table_name], "
ORDER BY
  \"Patientennummer\";")


# simple cast to date
looplist <- list("dt.encounterstart" = list(var1 = "KH-internes-Kennzeichen", var2 = "Aufnahmedatum"),
                 "dt.encounterend" = list(var1 = "KH-internes-Kennzeichen", var2 = "Entlassungsdatum"),
                 "dt.procedure" = list(var1 = "KH-internes-Kennzeichen", var2 = "OPS-Kode"),
                 "dt.provider" = list(var1 = "KH-internes-Kennzeichen", var2 = "FAB"),
                 "dt.ageindays" = list(var1 = "KH-internes-Kennzeichen", var2 = "Alter-in-Tagen-am-Aufnahmetag"),
                 "dt.ageinyears" = list(var1 = "KH-internes-Kennzeichen", var2 = "Alter-in-Jahren-am-Aufnahmetag"),
                 "dt.admission" = list(var1 = "KH-internes-Kennzeichen", var2 = "Aufnahmeanlass"),
                 "dt.hospitalization" = list(var1 = "KH-internes-Kennzeichen", var2 = "Aufnahmegrund"),
                 "dt.discharge" = list(var1 = "KH-internes-Kennzeichen", var2 = "Entlassungsgrund"),
                 "dt.ventilation" = list(var1 = "KH-internes-Kennzeichen", var2 = "Beatmungsstunden"),
                 "dt.condition" = list(var1 = "KH-internes-Kennzeichen", var2 = "ICD-Kode"),
                 "dt.conditioncategory" = list(var1 = "KH-internes-Kennzeichen", var2 = "Diagnoseart"),
                 "dt.proceduredate" = list(var1 = "KH-internes-Kennzeichen", var2 = "OPS-Datum"),
                 "dt.providerstart" = list(var1 = "KH-internes-Kennzeichen", var2 = "FAB-Aufnahmedatum"),
                 "dt.providerend" = list(var1 = "KH-internes-Kennzeichen", var2 = "FAB-Entlassungsdatum"))

for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "
SELECT
  \"", looplist[[i]]$var1, "\"\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var1,variable_name], "\",
  \"", looplist[[i]]$var2, "\"\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var2,variable_name], "\"
FROM
  p21.", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
ORDER BY
  \"", looplist[[i]]$var1, "\";")
  )
}

# where clause without left outer join on case-id
looplist <- list("dt.procedure_medication" = list(var1 = "KH-internes-Kennzeichen", var2 = "OPS-Kode"))


for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "
SELECT
  \"", looplist[[i]]$var1, "\"\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var1,variable_name], "\",
  \"", looplist[[i]]$var2, "\"\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var2,variable_name], "\"
FROM
  p21.", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
WHERE
  \"OPS-Kode\" LIKE '6-00%'
ORDER BY
  \"", looplist[[i]]$var1, "\";")
  )
}


vec <- c("dt.patient", "dt.gender", "dt.zipcode", "dt.birthdate",
         "dt.encounter", "dt.encounterstart", "dt.encounterend",
         "dt.ageindays", "dt.ageinyears", "dt.admission", "dt.hospitalization",
         "dt.discharge", "dt.ventilation",
         "dt.condition", "dt.conditioncategory",
         "dt.procedure", "dt.proceduredate",
         "dt.procedure_medication",
         "dt.provider", "dt.providerstart", "dt.providerend")
         #"pl.atemp.item01", "pl.atemp.item02", "pl.atemp.item03", "pl.atemp.item04")
string_list <- sapply(vec, function(i){eval(parse(text=i))}, simplify = F, USE.NAMES = T)

jsonlist <- toJSON(string_list, pretty = T, auto_unbox = F)
writeLines(jsonlist, "./inst/application/_utilities/SQL/SQL_p21staging.JSON")


# # debugging
# txt <- fromJSON("./sql.JSON")
# txt$"dt_patient.db"
