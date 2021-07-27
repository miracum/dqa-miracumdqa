# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2021 Universitätsklinikum Erlangen
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

# nolint start

# read mdr
mdr <- DQAstats::read_mdr(utils = "inst/application/_utilities/", mdr_filename = "mdr.csv")
mdr <- mdr[source_system_name == "fhirgw", ]


replace_this <- function(string, replace) {
  str_sp <- unlist(strsplit(string, "\tAS\t", fixed = T))
  outstring <- paste0(
    "REPLACE(",
    str_sp[1],
    ", '",
    replace,
    "', '')\tAS\t",
    str_sp[2]
  )
  return(outstring)
}

to_date <- function(string, todate) {
  str_sp <- unlist(strsplit(string, "\tAS\t", fixed = T))
  outstring <- paste0(
    "TO_DATE(",
    str_sp[1],
    ", 'YYYY-MM-DD')\tAS\t",
    str_sp[2]
  )
  return(outstring)
}


select_vars <- function(mdr_use, pattern = NULL, replace = NULL, todate = NULL) {
  sel_vars <- sapply(mdr_use[,get("source_variable_name")], function(x){paste0("DATA ->> '", x, "'", "\tAS\t\"", mdr_use[source_variable_name==x,variable_name], "\"")})

  if (is.null(pattern)) {
    pattern <- ""
  }

  sel_vars <- sapply(
    X = seq_len(length(sel_vars)),
    FUN = function(x) {
      # "||" to access list elements (by default, the first is chosen)
      if (pattern == "array") {
        if (grepl("\\.", sel_vars[x])) {
          sel_vars[x] <- gsub("->>", "->", sel_vars[x])
          sel_vars[x] <- gsub("\\.", "' -> 0 ->> '", sel_vars[x])
        }
        # "." if you want to access data
      } else if (pattern == "array_second") {
        if (grepl("\\.", sel_vars[x])) {
          sel_vars[x] <- gsub("->>", "->", sel_vars[x])
          str_sp <- unlist(strsplit(sel_vars[x], ".", fixed = T))
          sel_vars[x] <- paste0(
            str_sp[1],
            "' -> '",
            str_sp[2],
            "' -> 0 ->> '",
            str_sp[3]
          )
        }
        # "." if you want to access data
      } else if (pattern == "array_third") {
        if (grepl("\\.", sel_vars[x])) {
          sel_vars[x] <- gsub("->>", "->", sel_vars[x])
          str_sp <- unlist(strsplit(sel_vars[x], ".", fixed = T))
          sel_vars[x] <- paste0(
            str_sp[1],
            "' -> '",
            str_sp[2],
            "' -> '",
            str_sp[3],
            "' -> 0 ->> '",
            str_sp[4]
          )
        }
        # "." if you want to access data
      } else if (pattern == "array_first_third") {
        if (grepl("\\.", sel_vars[x])) {
          sel_vars[x] <- gsub("->>", "->", sel_vars[x])
          str_sp <- unlist(strsplit(sel_vars[x], ".", fixed = T))
          sel_vars[x] <- paste0(
            str_sp[1],
            "' -> 0 -> '",
            str_sp[2],
            "' -> '",
            str_sp[3],
            "' -> 0 ->> '",
            str_sp[4]
          )
        }
        # "." if you want to access data
      } else if (pattern == "2,4") {
        print("yes")
        if (grepl("\\.", sel_vars[x])) {
          sel_vars[x] <- gsub("->>", "->", sel_vars[x])
          str_sp <- unlist(strsplit(sel_vars[x], ".", fixed = T))
          sel_vars[x] <- paste0(
            str_sp[1],
            "' -> '",
            str_sp[2],
            "' -> 0 -> '",
            str_sp[3],
            "' -> '",
            str_sp[4],
            "' -> 0 ->> '",
            str_sp[5]
          )
        }
        # "." if you want to access data
      } else if (pattern == "regular") {
        if (grepl("\\.", sel_vars[x])) {
          sel_vars[x] <- gsub("->>", "->", sel_vars[x])
          sel_vars[x] <- gsub("\\.", "' ->> '", sel_vars[x])
        }
      }


      if (!is.null(replace)) {
        sel_vars[x] <- replace_this(sel_vars[x], replace)
      } else if (isTRUE(todate)) {
        sel_vars[x] <- to_date(sel_vars[x], todate)
      }
      return(sel_vars[x])
    },
    simplify = TRUE,
    USE.NAMES = FALSE
  )

  if (length(sel_vars) > 1) {
    sel_vars <- paste(sel_vars, collapse = ",\n")
  }

  return(sel_vars)
}



mdr.use <- mdr[key=="dt.patient",]

sel_vars <- select_vars(mdr.use)

dt.patient <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	", mdr.use[source_variable_name=="id",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="id",sql_where], ";")



mdr.use <- mdr[key=="dt.birthdate",]
sel_vars <- select_vars(mdr.use)

dt.birthdate <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	", mdr.use[source_variable_name=="birthDate",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="birthDate",sql_where], ";")


mdr.use <- mdr[key=="dt.gender",]
sel_vars <- select_vars(mdr.use)

dt.gender <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	", mdr.use[source_variable_name=="gender",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="gender",sql_where], ";")


mdr.use <- mdr[key=="dt.zipcode",]
sel_vars <- select_vars(mdr.use, pattern = "array")

dt.zipcode <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	", mdr.use[source_variable_name=="address.postalCode",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="address.postalCode",sql_where], ";")


mdr.use <- mdr[key=="dt.encounter",]
sel_vars <- select_vars(mdr.use, pattern = "regular", replace = "Patient/")

dt.encounter <-
  paste0(
    "SELECT
	", sel_vars, "
FROM
	", mdr.use[source_variable_name=="id",source_table_name], "
WHERE
  ", mdr.use[source_variable_name=="id",sql_where], ";")


# cast to date
looplist <- list("dt.encounterstart" = list(var1 = "id", var2 = "period.start"),
                 "dt.encounterend" = list(var1 = "id", var2 = "period.end"))

for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "SELECT
  ", select_vars(mdr.use[source_variable_name==looplist[[i]]$var1,], pattern = "regular"), ",
  ", select_vars(mdr.use[source_variable_name==looplist[[i]]$var2,], pattern = "regular", todate = TRUE), "
FROM
	", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
WHERE
  ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], ";")
  )
}

# cast to date
looplist <- list("dt.proceduredate" = list(var1 = "encounter.reference", var2 = "performedDateTime"))

for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "SELECT
  ", select_vars(mdr.use[source_variable_name==looplist[[i]]$var1,], pattern = "regular", replace = "Encounter/"), ",
  ", select_vars(mdr.use[source_variable_name==looplist[[i]]$var2,], pattern = "regular", todate = TRUE), "
FROM
	", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
WHERE
  ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], ";")
  )
}

# mixed, array_second
looplist <- list("dt.condition" = list(var1 = "encounter.reference", var2 = "code.coding.code"),
                 "dt.procedure" = list(var1 = "encounter.reference", var2 = "code.coding.code"),
                 "dt.laboratory" = list(var1 = "encounter.reference", var2 = "code.coding.code"),
                 "dt.ventilation" = list(var1 = "encounter.reference", var2 = "code.coding.code"))

for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "SELECT
  ", select_vars(mdr.use[source_variable_name==looplist[[i]]$var1,], pattern = "regular", replace = "Encounter/"), ",
  ", select_vars(mdr.use[source_variable_name==looplist[[i]]$var2,], pattern = "array_second"), "
FROM
	", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
WHERE
  ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], ";")
  )
}

# mixed, array_third
looplist <- list("dt.discharge" = list(var1 = "id", var2 = "hospitalization.dischargeDisposition.coding.code"))

for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "SELECT
  ", select_vars(mdr.use[source_variable_name==looplist[[i]]$var1,]), ",
  ", select_vars(mdr.use[source_variable_name==looplist[[i]]$var2,], pattern = "array_third"), "
FROM
	", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
WHERE
  ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], ";")
  )
}

# mixed, array_first_third
looplist <- list("dt.hospitalization" = list(var1 = "id", var2 = "hospitalization.admitSource.coding.code"))

for (i in names(looplist)){

  mdr.use <- mdr[key==i,]

  assign(i, paste0(
    "SELECT
  ", select_vars(mdr.use[source_variable_name==looplist[[i]]$var1,]), ",
  ", select_vars(mdr.use[source_variable_name==looplist[[i]]$var2,], pattern = "array_third"), "
FROM
	", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
WHERE
  ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], ";")
  )
}


#
# # where clause without left outer join on case-id
# looplist <- list("dt.procedure_medication" = list(var1 = "encounter_num", var2 = "concept_cd"),
#                  "dt.provider" = list(var1 = "encounter_num", var2 = "tval_char"))
#
#
# for (i in names(looplist)){
#
#   mdr.use <- mdr[key==i,]
#
#   assign(i, paste0(
#     "
# SELECT
#   ", looplist[[i]]$var1, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var1,variable_name], "\",
#   ", looplist[[i]]$var2, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var2,variable_name], "\"
# FROM
#   fhirmiracum.", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
# WHERE
#   ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], "
# ORDER BY
#   ", looplist[[i]]$var1, ";")
#   )
# }
#
#
# # where clause with left outer join on case-id
# looplist <- list("dt.ageindays" = list(var1 = "encounter_num", var2 = "nval_num"),
#                   "dt.ageinyears" = list(var1 = "encounter_num", var2 = "nval_num"),
#                   "dt.admission" = list(var1 = "encounter_num", var2 = "tval_char"),
#                  "dt.conditioncategory" = list(var1 = "encounter_num", var2 = "modifier_cd"))
#
#
# for (i in names(looplist)){
#
#   mdr.use <- mdr[key==i,]
#
#   assign(i, paste0(
#     "SELECT
#   b.", looplist[[i]]$var1, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var1,variable_name], "\",
#   a.", looplist[[i]]$var2, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var2,variable_name], "\"
# FROM
#   fhirmiracum.encounter_mapping AS b
# LEFT OUTER JOIN (
# SELECT
#   ", looplist[[i]]$var1, ", ", looplist[[i]]$var2, "
# FROM
#   fhirmiracum.", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
# WHERE
#   ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], ") AS a ON
#   a.", looplist[[i]]$var1, " = b.", looplist[[i]]$var1, "
# ORDER BY
#   b.", looplist[[i]]$var1, ";")
#   )
# }
#
#
# # cast dates
# looplist <- list(
#                  "dt.providerstart" = list(var1 = "encounter_num", var2 = "start_date"),
#                  "dt.providerend" = list(var1 = "encounter_num", var2 = "end_date"))
#
#
# for (i in names(looplist)){
#
#   mdr.use <- mdr[key==i,]
#
#   assign(i, paste0(
#     "SELECT
#   ", looplist[[i]]$var1, "\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var1,variable_name], "\",
#   ", looplist[[i]]$var2, "::date\tAS\t\"", mdr.use[source_variable_name==looplist[[i]]$var2,variable_name], "\"
# FROM
#   fhirmiracum.", mdr.use[source_variable_name==looplist[[i]]$var2,source_table_name], "
# WHERE
#   ", mdr.use[source_variable_name==looplist[[i]]$var2,sql_where], "
# ORDER BY
#   ", looplist[[i]]$var1, ";")
#   )
# }
#
#
# # # create plausibility statements
# # for (i in c("pl.atemp.item01", "pl.atemp.item02", "pl.atemp.item03", "pl.atemp.item04")){
# #   mdr.use <- mdr[key==i,]
# #
# #   assign(i,
# #          paste0(
# #            "SELECT
# #   ob.encounter_num    AS    \"", mdr.use[source_variable_name=="encounter_num",variable_name], "\",
# #   ob.patient_num      AS    \"", mdr.use[source_variable_name=="patient_num",variable_name], "\",
# #   ob.concept_cd       AS    \"", mdr.use[source_variable_name=="concept_cd",variable_name], "\",
# #   pa.sex_cd           AS    \"", mdr.use[source_variable_name=="sex_cd",variable_name], "\"
# # FROM
# #   fhirmiracum.", mdr.use[source_variable_name=="encounter_num",source_table_name], " AS ob
# # LEFT OUTER JOIN
# #   fhirmiracum.patient_dimension AS pa ON ob.patient_num = pa.patient_num
# # WHERE
# #   ob.", mdr.use[source_variable_name=="sex_cd",sql_where], "
# # ORDER BY
# #   ob.encounter_num;"))
# # }
# #


vec <- c("dt.patient", "dt.gender", "dt.zipcode", "dt.birthdate"
         , "dt.encounter", "dt.encounterstart", "dt.encounterend"
         # , "dt.ageindays", "dt.ageinyears", "dt.admission"
         , "dt.hospitalization"
         , "dt.discharge", "dt.ventilation"
         , "dt.condition"
         #, "dt.conditioncategory"
         , "dt.procedure", "dt.proceduredate"
         # , "dt.procedure_medication"
         , "dt.laboratory"
         # , "dt.provider", "dt.providerstart", "dt.providerend"
)
#"pl.atemp.item01", "pl.atemp.item02", "pl.atemp.item03", "pl.atemp.item04")
string_list <- sapply(vec, function(i){eval(parse(text=i))}, simplify = F, USE.NAMES = T)

jsonlist <- toJSON(string_list, pretty = T, auto_unbox = F)
writeLines(jsonlist, "./inst/application/_utilities/SQL/SQL_fhirgw.JSON")


# # debugging
# txt <- fromJSON("./sql.JSON")
# txt$"dt_patient.db"

# nolint end
