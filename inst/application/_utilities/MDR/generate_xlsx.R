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
mdr <- fread(paste0(getwd(), "/inst/application/_utilities/MDR/mdr.csv"))
mdr[,plausibility_relation:=as.character(plausibility_relation)]
mdr[,("value_set"):=gsub("\"\"", "\"", get("value_set"))][get("value_set")=="",("value_set"):=NA]
mdr[,("plausibility_relation"):=gsub("\"\"", "\"", get("plausibility_relation"))][get("plausibility_relation")=="",("plausibility_relation"):=NA]
mdr[get("source_system")=="",("source_system"):=NA]
mdr[get("sql_from")=="",("sql_from"):=NA]
mdr[get("sql_where")=="",("sql_where"):=NA]
mdr[get("sql_join_type")=="",("sql_join_type"):=NA]
mdr[get("sql_join_on")=="",("sql_join_on"):=NA]


# create hierarchical list structure
mdr_subset <- mdr[get("dqa_assessment")==1 & get("source_system")=="p21csv",]
mdr_list <- sapply(mdr_subset[,get("designation")], function(name){
return(list("id" = which(mdr_subset[,get("designation")]==name),
            "designation" = name,
            "definition" = mdr_subset[get("designation")==name,get("definition")],
            "validations" = ifelse(mdr_subset[get("designation")==name,get("variable_type")]=="factor", "permittedValues",
                                   ifelse(mdr_subset[get("designation")==name,get("variable_type")]=="integer", "integer",
                                          ifelse(mdr_subset[get("designation")==name,get("variable_type")]=="date", "calendar", NA)))))
}, USE.NAMES = T, simplify = F)


# create source_system specific slots
sourceSlot <- function(mdr, sourcesystem, name){
  subs <- mdr[get("source_system") == sourcesystem & get("designation")==name & get("dqa_assessment")==1,]
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
  if (nrow(mdr[get("source_system") == sourcesystem & get("key")==subs[,get("key")] & get("dqa_assessment")==0,]) > 0){
    helps <- mdr[get("source_system") == sourcesystem & get("key")==subs[,get("key")] & get("dqa_assessment")==0,]
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
dqaSlot <- function(mdr, sourcesystem = "p21csv", name){
  subs <- mdr[get("source_system") == sourcesystem & get("designation")==name & get("dqa_assessment")==1,]
  outlist <- list("dqa_assessment" = 1,
                  "variable_name" = subs[,get("variable_name")],
                  "fhir" = subs[,get("fhir")],
                  "variable_type" = subs[,get("variable_type")])
  if (!is.na(subs[,get("plausibility_relation")])){
    outlist <- c(outlist, list("plausibility_relation" = subs[,get("plausibility_relation")]))
  }
  return(jsonlite::toJSON(outlist))
}


# add slots
for (i in names(mdr_list)){
  mdr_list[[i]]$slots$dqa <- dqaSlot(mdr, name = i)
  for (j in unique(mdr[,get("source_system")])){
    if (!is.na(j)){
      mdr_list[[i]]$slots[[j]] <- sourceSlot(mdr, sourcesystem = j, name = i)
    }
  }
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
xlsx_dataelements[1, "temp_id"] <- 0
xlsx_dataelements[1, "element_type"] <- "dataelementgroup"

# read "slots" sheets
xlsx_slots <- openxlsx::read.xlsx(wb, sheet = which(wb$sheet_names == "slots"))
colnames(xlsx_slots) <- gsub("\\.", " ", colnames(xlsx_slots))

# init slot_row
slot_row <<- 1

for (i in 1:length(mdr_list)){
  # write dataelements
  xlsx_dataelements[i+1, "temp_id"] <- mdr_list[[i]]$id
  xlsx_dataelements[i+1, "parent_id"] <- mdr_list[[i]]$id
  xlsx_dataelements[i+1, "element_type"] <- "dataelement"
  xlsx_dataelements[i+1, "definition_id"] <- mdr_list[[i]]$id
  xlsx_dataelements[i+1, "validation_type"] <- mdr_list[[i]]$validations
  # generate formula
  f <- paste0("=SVERWEIS(dataelements!$D", i+2, ";definitions!$A:$D;3;FALSCH)")
  class(f) <- c(class(f), "formula")
  xlsx_dataelements[i+1, "Designation (first defined language)"] <- f

  # write definitions
  xlsx_definitions[i, "id"] <- mdr_list[[i]]$id
  xlsx_definitions[i, "language"] <- "de"
  xlsx_definitions[i, "designation"] <- mdr_list[[i]]$designation
  xlsx_definitions[i, "definition"] <- mdr_list[[i]]$definition

  # write slots
  for (j in 1:length(mdr_list[[i]]$slots)){
    xlsx_slots[slot_row, "dataelement_id"] <- mdr_list[[i]]$id
    xlsx_slots[slot_row, "key"] <- names(mdr_list[[i]]$slots)[j]
    xlsx_slots[slot_row, "value"] <- mdr_list[[i]]$slots[[j]]
    # generate formula
    f <- paste0("=SVERWEIS($A", slot_row + 1, ";dataelements!A:G;7;FALSCH)")
    class(f) <- c(class(f), "formula")
    xlsx_slots[slot_row, "Designation of date element (first defined language)"] <- f
    slot_row <<- slot_row + 1
  }
}

openxlsx::writeDataTable(wb, "dataelements", x = xlsx_dataelements)
openxlsx::writeDataTable(wb, "definitions", x = xlsx_definitions)
openxlsx::writeDataTable(wb, "slots", x = xlsx_slots)


# write xlsx
openxlsx::saveWorkbook(wb, "inst/application/_utilities/MDR/XLSX/mdr-import_DQA.xlsx", overwrite = T)



