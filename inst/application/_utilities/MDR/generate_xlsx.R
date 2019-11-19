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

library(data.table)
library(openxlsx)
library(jsonlite)

# read mdr
mdr <- DQAstats::read_mdr(utils = "inst/application/_utilities/")

# the system, where the "master information" is stored (definition, validations, etc.)
master_system <- "p21csv"


# create hierarchical list structure
mdr_subset <- mdr[get("dqa_assessment")==1 & get("source_system_name")==master_system,]
mdr_list <- sapply(mdr_subset[,get("designation")], function(name){
  return(list("id" = which(mdr_subset[,get("designation")]==name),
              "designation" = name,
              "definition" = mdr_subset[get("designation")==name,get("definition")],
              "validations" = mdr_subset[get("designation")==name,get("variable_type")]))
}, USE.NAMES = T, simplify = F)


# create source_system specific slots
sourceSlot <- function(mdr, sourcesystem, name){
  subs <- mdr[get("source_system_name") == sourcesystem & get("designation")==name & get("dqa_assessment")==1,]
  outlist <- list("key" = subs[,get("key")],
                  "variable_name" = subs[,get("variable_name")],
                  "fhir" = subs[,get("fhir")],
                  "source_variable_name" = subs[,get("source_variable_name")],
                  "source_table_name" = subs[,get("source_table_name")])
  if (!is.na(subs[,get("constraints")])){
    outlist <- c(outlist, list("constraints" = subs[,get("constraints")]))
  }
  if (!is.na(subs[,get("value_threshold")])){
    outlist <- c(outlist, list("value_threshold" = subs[,get("value_threshold")]))
  }
  if (!is.na(subs[,get("data_map")])){
    outlist <- c(outlist, list("data_map" = subs[,get("data_map")]))
  }
  if (!is.na(subs[,get("sql_from")])){
    outlist <- c(outlist, list("sql_from" = subs[,get("sql_from")]))
  }
  if (!is.na(subs[,get("sql_join_on")])){
    outlist <- c(outlist, list("sql_join_on" = subs[,get("sql_join_on")]))
  }
  if (!is.na(subs[,get("sql_join_type")])){
    outlist <- c(outlist, list("sql_join_type" = subs[,get("sql_join_type")]))
  }
  if (!is.na(subs[,get("sql_where")])){
    outlist <- c(outlist, list("sql_where" = subs[,get("sql_where")]))
  }
  if (nrow(mdr[get("source_system_name") == sourcesystem & get("key")==subs[,get("key")] & get("dqa_assessment")==0,]) > 0){
    helps <- mdr[get("source_system_name") == sourcesystem & get("key")==subs[,get("key")] & get("dqa_assessment")==0,]
    helpsout <- list()
    for (i in helps[,get("variable_name")]){
      helpsout[[i]] <- list("designation" = helps[get("variable_name")==i,get("designation")],
                            "source_variable_name" = helps[get("variable_name")==i,get("source_variable_name")],
                            "source_table_name" = helps[get("variable_name")==i,get("source_table_name")],
                            "fhir" = helps[get("variable_name")==i,get("fhir")])
      if (!is.na(helps[,get("sql_from")])){
        helpsout[[i]] <- c(helpsout[[i]], list("sql_from" = helps[,get("sql_from")]))
      }
      if (!is.na(helps[,get("sql_join_on")])){
        helpsout[[i]] <- c(helpsout[[i]], list("sql_join_on" = helps[,get("sql_join_on")]))
      }
      if (!is.na(helps[,get("sql_join_type")])){
        helpsout[[i]] <- c(helpsout[[i]], list("sql_join_type" = helps[,get("sql_join_type")]))
      }
      if (!is.na(helps[,get("sql_where")])){
        helpsout[[i]] <- c(helpsout[[i]], list("sql_where" = helps[,get("sql_where")]))
      }
    }
    outlist$helper_vars <- helpsout
  }
  return(jsonlite::toJSON(outlist))
}

# create dq-slots
dqaSlot <- function(mdr, sourcesystem = master_system, name){
  subs <- mdr[get("source_system_name") == sourcesystem & get("designation")==name & get("dqa_assessment")==1,]
  outlist <- list("dqa_assessment" = 1,
                  "variable_name" = subs[,get("variable_name")],
                  "fhir" = subs[,get("fhir")])
  if (!is.na(subs[,get("plausibility_relation")])){
    outlist <- c(outlist, list("plausibility_relation" = subs[,get("plausibility_relation")]))
  }
  for (j in unique(mdr[,get("source_system_type")])) {
    if (!is.na(j)) {
      if (is.null(outlist[[j]])) {
        outlist[[j]] <- list()
      }
      for (k in unique(mdr[get("source_system_type") == j, get("source_system_name")])) {
        if (!is.na(k)) {
          outlist[[j]][[k]] <- sourceSlot(mdr, sourcesystem = k, name = name)
        }
      }
    }
  }
  return(jsonlite::toJSON(outlist))
}


# add slots
for (i in names(mdr_list)){
  mdr_list[[i]]$slots$dqa <- dqaSlot(mdr, name = i)
}


# create workbook
wb <- openxlsx::loadWorkbook("inst/application/_utilities/MDR/XLSX/mdr-import_template.xlsx")
wb$sheet_names

# read "Info" sheet
xlsx_info <- openxlsx::read.xlsx(wb, sheet = which(wb$sheet_names == "Info"))
xlsx_info$name <- "dqa_tool"
openxlsx::writeDataTable(wb, "Info", x = xlsx_info)


# read "dataelements" sheet
xlsx_dataelements <- openxlsx::read.xlsx(wb, sheet = which(wb$sheet_names == "dataelements"))
colnames(xlsx_dataelements) <- gsub("\\.", " ", colnames(xlsx_dataelements))

# read "definitions" sheets
xlsx_definitions <- openxlsx::read.xlsx(wb, sheet = which(wb$sheet_names == "definitions"))

# read "validations_permittedValues" sheets
xlsx_validations_permittedValues <- openxlsx::read.xlsx(wb, sheet = which(wb$sheet_names == "validations_permittedValues"))
colnames(xlsx_validations_permittedValues) <- gsub("\\.", " ", colnames(xlsx_validations_permittedValues))

# read "validations_integer" sheets
xlsx_validations_integer <- openxlsx::read.xlsx(wb, sheet = which(wb$sheet_names == "validations_integer"))
colnames(xlsx_validations_integer) <- gsub("\\.", " ", colnames(xlsx_validations_integer))

# read "validations_string" sheets
xlsx_validations_string <- openxlsx::read.xlsx(wb, sheet = which(wb$sheet_names == "validations_string"))
colnames(xlsx_validations_string) <- gsub("\\.", " ", colnames(xlsx_validations_string))

# read "validations_calendar" sheets
xlsx_validations_calendar <- openxlsx::read.xlsx(wb, sheet = which(wb$sheet_names == "validations_calendar"))
colnames(xlsx_validations_calendar) <- gsub("\\.", " ", colnames(xlsx_validations_calendar))

# read "slots" sheets
xlsx_slots <- openxlsx::read.xlsx(wb, sheet = which(wb$sheet_names == "slots"))
colnames(xlsx_slots) <- gsub("\\.", " ", colnames(xlsx_slots))

# write dataelementgroup
xlsx_dataelements[1, "temp_id"] <- 0
xlsx_dataelements[1, "element_type"] <- "dataelementgroup"
xlsx_dataelements[1, "definition_id"] <- 0
f <- paste0("=SVERWEIS(dataelements!$D", 2, ";definitions!$A:$D;3;FALSCH)")
class(f) <- c(class(f), "formula")
xlsx_dataelements[1, "Designation (first defined language)"] <- f
xlsx_definitions[1, "id"] <- 0
xlsx_definitions[1, "language"] <- "de"
xlsx_definitions[1, "designation"] <- "Paragraph 21 (DQA)"
xlsx_definitions[1, "definition"] <- "Diese Gruppe enthält die Datenelemente des Paragraph 21, die im Rahmen der DQ-Analyse geprüft werden."

# init rows
slot_row <<- 1
permittedVals_row <<- 1
integer_row <<- 1
calendar_row <<- 1
string_row <<- 1
definition_row <<- 2

# init validation ids
permittedvalues_id <<- 1
permittedvalues_definition_id <<- 1000
string_id <<- 1
integer_id <<- 1
calendar_id <<- 1


for (tempid in 1:length(mdr_list)){
  updated_permittedValues <- FALSE
  # write dataelements
  xlsx_dataelements[tempid+1, "temp_id"] <- tempid
  xlsx_dataelements[tempid+1, "parent_id"] <- 0
  xlsx_dataelements[tempid+1, "element_type"] <- "dataelement"
  xlsx_dataelements[tempid+1, "definition_id"] <- tempid
  xlsx_dataelements[tempid+1, "validation_type"] <- mdr_list[[tempid]]$validations
  # generate formula
  f <- paste0("=SVERWEIS(dataelements!$D", tempid+2, ";definitions!$A:$D;3;FALSCH)")
  class(f) <- c(class(f), "formula")
  xlsx_dataelements[tempid+1, "Designation (first defined language)"] <- f

  # write definitions
  xlsx_definitions[definition_row, "id"] <- tempid
  xlsx_definitions[definition_row, "language"] <- "de"
  xlsx_definitions[definition_row, "designation"] <- mdr_list[[tempid]]$designation
  xlsx_definitions[definition_row, "definition"] <- mdr_list[[tempid]]$definition

  # write slots
  for (j in 1:length(mdr_list[[tempid]]$slots)){
    xlsx_slots[slot_row, "dataelement_id"] <- tempid
    xlsx_slots[slot_row, "key"] <- names(mdr_list[[tempid]]$slots)[j]
    xlsx_slots[slot_row, "value"] <- mdr_list[[tempid]]$slots[[j]]
    # generate formula
    f <- paste0("=SVERWEIS($A", slot_row + 1, ";dataelements!A:G;7;FALSCH)")
    class(f) <- c(class(f), "formula")
    xlsx_slots[slot_row, "Designation of date element (first defined language)"] <- f
    slot_row <<- slot_row + 1
  }

  # permitted values
  if (mdr_list[[tempid]]$validations == "permittedValues") {
    xlsx_dataelements[tempid+1, "validation_id"] <- permittedvalues_id

    get_json <- jsonlite::fromJSON(jsonlite::fromJSON(mdr_list[[tempid]]$slots$dqa)$csv[[master_system]])

    value_set <- unlist(
      strsplit(
          jsonlite::fromJSON(
            get_json$constraints)$value_set, ", ", fixed = T)
    )

    # augment definition_row + 1, otherwise we overwrite the dataelement's definition
    definition_row <<- definition_row + 1

    for (level in value_set) {
      xlsx_validations_permittedValues[permittedVals_row, "id"] <- permittedvalues_id
      xlsx_validations_permittedValues[permittedVals_row, "value"] <- level
      xlsx_validations_permittedValues[permittedVals_row, "definition_id"] <- permittedvalues_definition_id
      f <- paste0("=SVERWEIS(validations_permittedValues!$A", permittedVals_row+1, "; WENN(dataelements!$E:$E=\"permittedValues\"; dataelements!$F:$G);2)")
      class(f) <- c(class(f), "formula")
      xlsx_validations_permittedValues[permittedVals_row, "Designation of data element (in first defined language)"] <- f
      f <- paste0("=SVERWEIS($C", permittedVals_row+1, ";definitions!$A:$C;3;FALSCH)")
      class(f) <- c(class(f), "formula")
      xlsx_validations_permittedValues[permittedVals_row, "Designation of value (in first defined language)"] <- f

      xlsx_definitions[definition_row, "id"] <- permittedvalues_definition_id
      xlsx_definitions[definition_row, "language"] <- "de"
      xlsx_definitions[definition_row, "designation"] <- level
      xlsx_definitions[definition_row, "definition"] <- level

      permittedVals_row <<- permittedVals_row + 1
      definition_row <<- definition_row + 1
      permittedvalues_definition_id <<- permittedvalues_definition_id + 1
    }
    updated_permittedValues <- TRUE
    permittedvalues_id <<- permittedvalues_id + 1
  }


  # integer
  if (mdr_list[[tempid]]$validations == "integer"){
    xlsx_dataelements[tempid+1, "validation_id"] <- integer_id

    get_json <- jsonlite::fromJSON(jsonlite::fromJSON(mdr_list[[tempid]]$slots$dqa)$csv[[master_system]])

    range <- jsonlite::fromJSON(
        get_json$constraints)$range

    xlsx_validations_integer[integer_row, "id"] <- integer_id
    xlsx_validations_integer[integer_row, "range_from"] <- range$min
    xlsx_validations_integer[integer_row, "range_to"] <- range$max
    xlsx_validations_integer[integer_row, "unit_of_measure"] <- range$unit
    f <- paste0("=SVERWEIS(validations_integer!$A", integer_row+1, ";WENN(dataelements!$E:$E=\"integer\";dataelements!$F:$G);2;FALSCH)")
    class(f) <- c(class(f), "formula")
    xlsx_validations_integer[integer_row, "Designation of data element (in first defined language)"] <- f

    integer_row <<- integer_row + 1
    integer_id <<- integer_id + 1
  }

  # string
  if (mdr_list[[tempid]]$validations == "string"){
    xlsx_dataelements[tempid+1, "validation_id"] <- string_id

    get_json <- jsonlite::fromJSON(jsonlite::fromJSON(mdr_list[[tempid]]$slots$dqa)$csv[[master_system]])

    regex <- jsonlite::fromJSON(
        get_json$constraints)$regex

    xlsx_validations_string[string_row, "id"] <- string_id
    xlsx_validations_string[string_row, "max_length"] <- "30"
    xlsx_validations_string[string_row, "regex"] <- regex
    f <- paste0("=SVERWEIS(validations_string!$A", string_row+1, ";WENN(dataelements!$E:$E=\"string\";dataelements!$F:$G);2;FALSCH)")
    class(f) <- c(class(f), "formula")
    xlsx_validations_string[string_row, "Designation of data element (in first defined language)"] <- f

    string_row <<- string_row + 1
    string_id <<- string_id + 1
  }


  # calendar
  if (mdr_list[[tempid]]$validations == "calendar"){
    xlsx_dataelements[tempid+1, "validation_id"] <- calendar_id

    xlsx_validations_calendar[calendar_row, "id"] <- calendar_id
    xlsx_validations_calendar[calendar_row, "format"] <- "yyyy-MM-dd"
    f <- paste0("=SVERWEIS(validations_calendar!$A", calendar_row+1, ";WENN(dataelements!$E:$E=\"calendar\";dataelements!$F:$G);2)")
    class(f) <- c(class(f), "formula")
    xlsx_validations_calendar[calendar_row, "Designation of data element (in first defined language)"] <- f

    calendar_row <<- calendar_row + 1
    calendar_id <<- calendar_id + 1
  }

  if (!updated_permittedValues){
    definition_row <<- definition_row + 1
  }
}

openxlsx::writeDataTable(wb, "dataelements", x = xlsx_dataelements)
openxlsx::writeDataTable(wb, "definitions", x = xlsx_definitions)
openxlsx::writeDataTable(wb, "validations_permittedValues", x = xlsx_validations_permittedValues)
openxlsx::writeDataTable(wb, "validations_string", x = xlsx_validations_string)
openxlsx::writeDataTable(wb, "validations_integer", x = xlsx_validations_integer)
openxlsx::writeDataTable(wb, "validations_calendar", x = xlsx_validations_calendar)
openxlsx::writeDataTable(wb, "slots", x = xlsx_slots)


# write xlsx
openxlsx::saveWorkbook(wb, "inst/application/_utilities/MDR/XLSX/mdr-import_DQA.xlsx", overwrite = T)



jsonlist <- toJSON(mdr_list, pretty = T, auto_unbox = F)
writeLines(jsonlist, "./inst/application/_utilities/MDR/DQA_MDR.JSON")
