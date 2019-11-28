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


#' @title DQA-MDR to Samply.MDR Converter Function
#'
#' @param master_system_name The name of the master system. Currently, the only
#'   allowed argument is `p21csv`. All necessary MDR items, including
#'   `definition` and `dqa_assessment`, are stored on the master system level
#'   in the metadata repository.
#' @param mdr_filename A character string. The name of the DQA-MDR CSV file
#'   (default: 'mdr.csv').
#' @inheritParams launch_dqa_tool
#'
#' @export
#'
mdr_to_samply <- function(utilspath = "inst/application/_utilities/",
                          mdr_filename = "mdr.csv",
                          master_system_name = "p21csv") {

  stopifnot(
    is.character(utilspath),
    is.character(mdr_filename),
    mdr_filename == "mdr.csv",
    is.character(master_system_name),
    master_system_name == "p21csv"
  )

  rv <- list()

  rv$utilspath <- DQAstats::clean_path_name(utilspath)

  # read mdr
  rv$mdr <- DQAstats::read_mdr(
    utils_path = rv$utilspath,
    mdr_filename = mdr_filename
  )
  stopifnot(data.table::is.data.table(rv$mdr))

  # create hierarchical list structure
  rv$mdr_subset <- rv$mdr[get("dqa_assessment") ==
                         1 & get("source_system_name") ==
                         master_system_name, ]

  rv$mdr_list <- sapply(
    rv$mdr_subset[, get("designation")],
    function(name) {
      return(list("id" = which(rv$mdr_subset[, get("designation")] ==
                                 name),
                  "designation" = name,
                  "definition" = rv$mdr_subset[get("designation") ==
                                              name, get("definition")],
                  "validations" = rv$mdr_subset[get("designation") ==
                                               name, get("variable_type")]))
    }, USE.NAMES = T, simplify = F)


  # add slots
  for (i in names(rv$mdr_list)) {
    rv$mdr_list[[i]]$slots$dqa <- dqa_slot(
      mdr = rv$mdr,
      sourcesystem = master_system_name,
      name = i
    )
  }

  # create workbook
  wbfilename <- paste0(rv$utilspath, "MDR/XLSX/mdr-import_template.xlsx")
  stopifnot(file.exists(wbfilename))

  # read template
  wb <- openxlsx::loadWorkbook(file = wbfilename)
  wb$sheet_names

  # read "Info" sheet
  xlsx_info <- openxlsx::read.xlsx(
    wb,
    sheet = which(wb$sheet_names == "Info")
  )
  xlsx_info$name <- "dqa_tool"
  openxlsx::writeDataTable(wb, "Info", x = xlsx_info)

  # read "dataelements" sheet
  xlsx_dataelements <- openxlsx::read.xlsx(
    wb,
    sheet = which(wb$sheet_names == "dataelements")
  )
  colnames(xlsx_dataelements) <-
    gsub("\\.", " ", colnames(xlsx_dataelements))

  # read "definitions" sheets
  xlsx_definitions <- openxlsx::read.xlsx(
    wb,
    sheet = which(wb$sheet_names == "definitions")
  )

  # read "validations_permittedValues" sheets
  xlsx_validations_permit_vals <- openxlsx::read.xlsx(
    wb,
    sheet = which(wb$sheet_names == "validations_permittedValues")
  )
  colnames(xlsx_validations_permit_vals) <-
    gsub("\\.", " ", colnames(xlsx_validations_permit_vals))

  # read "validations_integer" sheets
  xlsx_validations_integer <- openxlsx::read.xlsx(
    wb,
    sheet = which(wb$sheet_names == "validations_integer")
  )
  colnames(xlsx_validations_integer) <-
    gsub("\\.", " ", colnames(xlsx_validations_integer))

  # read "validations_string" sheets
  xlsx_validations_string <- openxlsx::read.xlsx(
    wb,
    sheet = which(wb$sheet_names == "validations_string")
  )
  colnames(xlsx_validations_string) <-
    gsub("\\.", " ", colnames(xlsx_validations_string))

  # read "validations_calendar" sheets
  xlsx_validations_calendar <- openxlsx::read.xlsx(
    wb,
    sheet = which(wb$sheet_names == "validations_calendar")
  )
  colnames(xlsx_validations_calendar) <-
    gsub("\\.", " ", colnames(xlsx_validations_calendar))

  # read "slots" sheets
  xlsx_slots <- openxlsx::read.xlsx(
    wb,
    sheet = which(wb$sheet_names == "slots")
  )
  colnames(xlsx_slots) <-
    gsub("\\.", " ", colnames(xlsx_slots))

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
  xlsx_definitions[1, "definition"] <- paste0(
    "Diese Gruppe enth\u00E4lt die Datenelemente des Paragraph 21, ",
    "die im Rahmen der DQ-Analyse gepr\u00FCft werden."
  )

  # init rows
  slot_row <- 1
  permitted_vals_row <- 1
  integer_row <- 1
  calendar_row <- 1
  string_row <- 1
  definition_row <- 2

  # init validation ids
  permittedvalues_id <- 1
  permittedvalues_definition_id <- 1000
  string_id <- 1
  integer_id <- 1
  calendar_id <- 1


  for (tempid in seq_len(length(rv$mdr_list))) {

    updated_permitted_values <- FALSE
    # write dataelements
    xlsx_dataelements[tempid + 1, "temp_id"] <- tempid
    xlsx_dataelements[tempid + 1, "parent_id"] <- 0
    xlsx_dataelements[tempid + 1, "element_type"] <- "dataelement"
    xlsx_dataelements[tempid + 1, "definition_id"] <- tempid
    xlsx_dataelements[tempid + 1, "validation_type"] <-
      rv$mdr_list[[tempid]]$validations
    # generate formula
    f <- paste0("=SVERWEIS(dataelements!$D",
                tempid + 2,
                ";definitions!$A:$D;3;FALSCH)")
    class(f) <- c(class(f), "formula")
    xlsx_dataelements[tempid + 1, "Designation (first defined language)"] <- f

    # write definitions
    xlsx_definitions[definition_row, "id"] <- tempid
    xlsx_definitions[definition_row, "language"] <- "de"
    xlsx_definitions[definition_row, "designation"] <-
      rv$mdr_list[[tempid]]$designation
    xlsx_definitions[definition_row, "definition"] <-
      rv$mdr_list[[tempid]]$definition

    # write slots
    for (j in seq_len(length(rv$mdr_list[[tempid]]$slots))) {
      xlsx_slots[slot_row, "dataelement_id"] <- tempid
      xlsx_slots[slot_row, "key"] <- names(rv$mdr_list[[tempid]]$slots)[j]
      xlsx_slots[slot_row, "value"] <- rv$mdr_list[[tempid]]$slots[[j]]
      # generate formula
      f <- paste0("=SVERWEIS($A", slot_row + 1, ";dataelements!A:G;7;FALSCH)")
      class(f) <- c(class(f), "formula")
      xlsx_slots[slot_row,
                 "Designation of date element (first defined language)"] <- f
      slot_row <- slot_row + 1
    }

    # permitted values
    if (rv$mdr_list[[tempid]]$validations == "permittedValues") {
      xlsx_dataelements[tempid + 1, "validation_id"] <- permittedvalues_id

      get_json <- jsonlite::fromJSON(
        jsonlite::fromJSON(
          rv$mdr_list[[tempid]]$slots$dqa
        )$csv[[master_system_name]]
      )

      value_set <- unlist(
        strsplit(
          jsonlite::fromJSON(
            get_json$constraints)$value_set, ", ", fixed = T)
      )

      # augment definition_row + 1, otherwise we overwrite the
      # dataelement's definition
      definition_row <- definition_row + 1

      for (level in value_set) {
        xlsx_validations_permit_vals[permitted_vals_row, "id"] <-
          permittedvalues_id
        xlsx_validations_permit_vals[permitted_vals_row, "value"] <-
          level
        xlsx_validations_permit_vals[permitted_vals_row, "definition_id"] <-
          permittedvalues_definition_id
        f <- paste0("=SVERWEIS(validations_permittedValues!$A",
                    permitted_vals_row + 1,
                    "; WENN(dataelements!$E:$E=\"permittedValues\"; ",
                    "dataelements!$F:$G);2)")
        class(f) <- c(class(f), "formula")
        cname <- "Designation of data element (in first defined language)"
        xlsx_validations_permit_vals[permitted_vals_row, cname] <- f
        f <- paste0("=SVERWEIS($C",
                    permitted_vals_row + 1,
                    ";definitions!$A:$C;3;FALSCH)")
        class(f) <- c(class(f), "formula")
        cname <- "Designation of value (in first defined language)"
        xlsx_validations_permit_vals[permitted_vals_row, cname] <- f

        xlsx_definitions[definition_row, "id"] <- permittedvalues_definition_id
        xlsx_definitions[definition_row, "language"] <- "de"
        xlsx_definitions[definition_row, "designation"] <- level
        xlsx_definitions[definition_row, "definition"] <- level

        permitted_vals_row <- permitted_vals_row + 1
        definition_row <- definition_row + 1
        permittedvalues_definition_id <- permittedvalues_definition_id + 1
      }
      updated_permitted_values <- TRUE
      permittedvalues_id <- permittedvalues_id + 1
    }


    # integer
    if (rv$mdr_list[[tempid]]$validations == "integer") {
      xlsx_dataelements[tempid + 1, "validation_id"] <- integer_id

      get_json <- jsonlite::fromJSON(
        jsonlite::fromJSON(
          rv$mdr_list[[tempid]]$slots$dqa
        )$csv[[master_system_name]]
      )

      range <- jsonlite::fromJSON(
        get_json$constraints)$range

      xlsx_validations_integer[integer_row, "id"] <- integer_id
      xlsx_validations_integer[integer_row, "range_from"] <- range$min
      xlsx_validations_integer[integer_row, "range_to"] <- range$max
      xlsx_validations_integer[integer_row, "unit_of_measure"] <- range$unit
      f <- paste0("=SVERWEIS(validations_integer!$A",
                  integer_row + 1,
                  ";WENN(dataelements!$E:$E=\"integer\";",
                  "dataelements!$F:$G);2;FALSCH)")
      class(f) <- c(class(f), "formula")
      cname <- "Designation of data element (in first defined language)"
      xlsx_validations_integer[integer_row, cname] <- f

      integer_row <- integer_row + 1
      integer_id <- integer_id + 1
    }

    # string
    if (rv$mdr_list[[tempid]]$validations == "string") {
      xlsx_dataelements[tempid + 1, "validation_id"] <- string_id

      get_json <- jsonlite::fromJSON(
        jsonlite::fromJSON(
          rv$mdr_list[[tempid]]$slots$dqa
        )$csv[[master_system_name]]
      )

      regex <- jsonlite::fromJSON(
        get_json$constraints)$regex

      xlsx_validations_string[string_row, "id"] <- string_id
      xlsx_validations_string[string_row, "max_length"] <- "30"
      xlsx_validations_string[string_row, "regex"] <- regex
      f <- paste0("=SVERWEIS(validations_string!$A",
                  string_row + 1,
                  ";WENN(dataelements!$E:$E=\"string\";",
                  "dataelements!$F:$G);2;FALSCH)")
      class(f) <- c(class(f), "formula")
      cname <- "Designation of data element (in first defined language)"
      xlsx_validations_string[string_row, cname] <- f

      string_row <- string_row + 1
      string_id <- string_id + 1
    }


    # calendar
    if (rv$mdr_list[[tempid]]$validations == "calendar") {
      xlsx_dataelements[tempid + 1, "validation_id"] <- calendar_id

      xlsx_validations_calendar[calendar_row, "id"] <- calendar_id
      xlsx_validations_calendar[calendar_row, "format"] <- "yyyy-MM-dd"
      f <- paste0("=SVERWEIS(validations_calendar!$A",
                  calendar_row + 1,
                  ";WENN(dataelements!$E:$E=\"calendar\";",
                  "dataelements!$F:$G);2)")
      class(f) <- c(class(f), "formula")
      cname <- "Designation of data element (in first defined language)"
      xlsx_validations_calendar[calendar_row, cname] <- f

      calendar_row <- calendar_row + 1
      calendar_id <- calendar_id + 1
    }

    if (!updated_permitted_values) {
      definition_row <- definition_row + 1
    }
  }

  openxlsx::writeDataTable(
    wb,
    "dataelements",
    x = xlsx_dataelements
  )
  openxlsx::writeDataTable(
    wb,
    "definitions",
    x = xlsx_definitions
  )
  openxlsx::writeDataTable(
    wb,
    "validations_permittedValues",
    x = xlsx_validations_permit_vals
  )
  openxlsx::writeDataTable(
    wb,
    "validations_string",
    x = xlsx_validations_string
  )
  openxlsx::writeDataTable(
    wb,
    "validations_integer",
    x = xlsx_validations_integer
  )
  openxlsx::writeDataTable(
    wb,
    "validations_calendar",
    x = xlsx_validations_calendar
  )
  openxlsx::writeDataTable(
    wb,
    "slots",
    x = xlsx_slots
  )


  # write xlsx
  openxlsx::saveWorkbook(
    wb,
    paste0(rv$utilspath, "MDR/XLSX/mdr-import_DQA.xlsx"),
    overwrite = T
  )



  jsonlist <- jsonlite::toJSON(
    rv$mdr_list, pretty = T, auto_unbox = F
  )
  writeLines(jsonlist, paste0(rv$utilspath, "MDR/DQA_MDR.JSON"))

}
