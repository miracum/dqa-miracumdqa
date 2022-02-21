# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2022 Universitätsklinikum Erlangen
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
#' @param base_url The URL of the Samply.MDR, from which the `namespace`
#'   should be imported.
#' @param namespace A character string. The name of the DQA-MDR namespace in
#'   the Samply.MDR (default: 'dqa').
#' @param master_system_type A character string. The type of the master system
#'   (the master system contains more information on the data elements;
#'   currently, 'csv' is the only allowed value.)
#' @param master_system_name A character string. The name of the master system
#'   (the master system contains more information on the data elements;
#'   currently, 'p21csv' is the only allowed value.)
#' @param headless A boolean (default: TRUE). Indicating, if the function is
#'   run only in the console (headless = TRUE) or on a GUI frontend
#'   (headless = FALSE).
#' @param logfile_dir A character string. Path to the logfile.
#'
#' @references \cite{D. Kadioglu, B. Breil, C. Knell, M. Lablans, S. Mate,
#'   D. Schlue, H. Serve, H. Storf, F. Ückert, T. Wagner, P. Weingardt,
#'   and H.-U. Prokosch, Samply.MDR - A Metadata Repository and Its
#'   Application in Various Research Networks, Studies in Health Technology
#'   and Informatics. (2018) 50–54. doi:10/gf963s.}
#'
#' @seealso \url{http://ebooks.iospress.nl/publication/50022}
#'
#' @export
#'
mdr_from_samply <- function(base_url,
                            namespace,
                            master_system_type = "csv",
                            master_system_name = "p21csv",
                            headless = TRUE,
                            logfile_dir
) {

  stopifnot(
    is.character(namespace),
    is.character(master_system_type),
    master_system_type %in% c("csv", "postgres"),
    is.character(master_system_name),
    master_system_name %in% c("p21csv", "p21staging"),
    dir.exists(logfile_dir)
  )

  if (isFALSE(headless)) {
    # Create a Progress object
    progress <- shiny::Progress$new()
    # Make sure it closes when we exit this reactive, even if
    # there's an error
    on.exit(progress$close())
    progress$set(message = "Querying Samply.MDR REST API",
                 value = 0)
  }

  # clean base url path
  base_url <- DIZtools::clean_path_name(base_url)

  # set members url
  member_url <- paste0(
    base_url,
    "namespaces/",
    namespace,
    "/members"
  )
  DIZtools::feedback(
    print_this = paste0("Member URL: ", member_url),
    findme = "f381e687ca",
    logfile_dir = logfile_dir,
    headless = headless
  )

  # get namespace members
  response_members <- jsonlite::fromJSON(
    txt = member_url
  )
  response_members$results <- data.table::as.data.table(
    response_members$results
  )
  # namespace must have exactly 1 member --> dqa
  stopifnot(
    nrow(response_members$results[get("type") ==
                                    "DATAELEMENTGROUP", ]) > 0,
    !is.null(response_members$results$id)
  )

  # init element_store
  element_store <- character(0)

  # add dataelements to element_store
  if (nrow(response_members$results[get("type") ==
                                    "DATAELEMENT", ]) > 0) {
    element_store <- response_members$results[
      get("type") == "DATAELEMENT" &
        get("identification.status") == "RELEASED", get("id")
      ]
  }

  get_groups <- TRUE
  group_ids <- response_members$results[
    get("type") == "DATAELEMENTGROUP" &
      get("identification.status") == "RELEASED", get("id")
    ]

  while (isTRUE(get_groups)) {
    g_ids <- character(0)

    for (gid in group_ids) {
      print(gid)
      group_results <- load_members(
        base_url = base_url,
        dataelementgroup_id = gid,
        logfile_dir = logfile_dir,
        headless = headless
      )

      if (length(group_results[["DATAELEMENTS"]]) > 0) {
        element_store <- c(
          element_store,
          group_results[["DATAELEMENTS"]]
        )
      }

      if (length(group_results[["DATAELEMENTGROUPS"]]) > 0) {
        g_ids <- c(
          g_ids,
          group_results[["DATAELEMENTGROUPS"]]
        )
      }
    }

    if (length(g_ids) == 0) {
      get_groups <- FALSE
    } else {
      group_ids <- g_ids
    }
  }


  # initialize empty data.table to store mdr
  outmdr <- data.table::data.table()

  # remove duplicates
  element_store <- element_store[!duplicated(element_store)]

  # loop over all dataelement-ids
  for (element_id in element_store) {

    # set dataelement url
    dataelement_url <- paste0(
      base_url,
      "dataelements/",
      element_id
    )

    msg <- paste("Dataelement URL:", dataelement_url)
    DIZtools::feedback(
      print_this = msg,
      logjs = isFALSE(headless),
      findme = "d05ebcefef",
      logfile_dir = logfile_dir,
      headless = headless
    )
    if (isFALSE(headless)) {
      # Increment the progress bar, and update the detail text.
      progress$inc(
        1 / length(element_store),
        detail = paste("reading", dataelement_url))
    }

    # test, if dqa slot is available (else ignore this element)
    response_dqa_slot <- jsonlite::fromJSON(
      txt = paste0(dataelement_url, "/slots"),
      simplifyDataFrame = T
    )

    if ("dqa" %in% response_dqa_slot$slot_name) {

      # get data elements
      response_dataelement <- jsonlite::fromJSON(
        txt = dataelement_url
      )
      # transform results to data.table
      response_dataelement$slots <- data.table::as.data.table(
        response_dataelement$slots
      )

      # set basic mdr variables
      append_basis <- data.table::data.table(
        "designation" = response_dataelement$designations$designation,
        "definition" = response_dataelement$designations$definition,
        "variable_type" = transform_data_types(
          response_dataelement$validation$datatype
        )
      )

      # extract dqa slot
      dqa_slot <- jsonlite::fromJSON(
        txt = response_dataelement$slots[get("slot_name") == "dqa",
                                         get("slot_value")]
      )

      # first look at all csv systems
      for (sys in names(dqa_slot$csv)) {
        if (sys == master_system_name) {
          # in a first level, extract our master_slot row
          csv_slot <- jsonlite::fromJSON(
            txt = dqa_slot$csv[[master_system_name]]
          )

          append_row <- cbind(
            append_basis,
            "source_system_type" = "csv",
            "source_system_name" = sys,
            data.table::as.data.table(
              csv_slot$base
            )
          )

          if (!is.null(dqa_slot$plausibility_relation)) {
            append_row <- cbind(
              append_row,
              "plausibility_relation" = dqa_slot$plausibility_relation
            )
          }

          # add master row to mdr
          outmdr <- data.table::rbindlist(list(
            outmdr,
            append_row
          ),
          fill = T)

          if (!is.null(csv_slot$helper_vars)) {

            for (h in names(csv_slot$helper_vars)) {
              append_row <- cbind(
                "source_system_type" = "csv",
                "source_system_name" = sys,
                data.table::as.data.table(
                  csv_slot$helper_vars[[h]]
                )
              )
              # add row to mdr
              outmdr <- data.table::rbindlist(list(
                outmdr,
                append_row
              ),
              fill = T)
            }
          }
        }
      }

      for (sys in names(dqa_slot$postgres)) {
        postgres_slot <- jsonlite::fromJSON(
          txt = dqa_slot$postgres[[sys]]
        )
        append_row <- cbind(
          append_basis,
          "source_system_type" = "postgres",
          "source_system_name" = sys,
          data.table::as.data.table(
            postgres_slot$base
          )
        )

        if (!is.null(dqa_slot$plausibility_relation)) {
          append_row <- cbind(
            append_row,
            "plausibility_relation" = dqa_slot$plausibility_relation
          )
        }

        # add row to mdr
        outmdr <- data.table::rbindlist(list(
          outmdr,
          append_row
        ),
        fill = T)

        if (!is.null(postgres_slot$helper_vars)) {

          for (h in names(postgres_slot$helper_vars)) {
            append_row <- cbind(
              "source_system_type" = "postgres",
              "source_system_name" = sys,
              data.table::as.data.table(
                postgres_slot$helper_vars[[h]]
              )
            )
            # add row to mdr
            outmdr <- data.table::rbindlist(list(
              outmdr,
              append_row
            ),
            fill = T)
          }
        }
      }

      for (sys in names(dqa_slot$oracle)) {
        oracle_slot <- jsonlite::fromJSON(
          txt = dqa_slot$oracle[[sys]]
        )
        append_row <- cbind(
          append_basis,
          "source_system_type" = "oracle",
          "source_system_name" = sys,
          data.table::as.data.table(
            oracle_slot$base
          )
        )

        if (!is.null(dqa_slot$plausibility_relation)) {
          append_row <- cbind(
            append_row,
            "plausibility_relation" = dqa_slot$plausibility_relation
          )
        }

        # add row to mdr
        outmdr <- data.table::rbindlist(list(
          outmdr,
          append_row
        ),
        fill = T)

        if (!is.null(oracle_slot$helper_vars)) {

          for (h in names(oracle_slot$helper_vars)) {
            append_row <- cbind(
              "source_system_type" = "oracle",
              "source_system_name" = sys,
              data.table::as.data.table(
                oracle_slot$helper_vars[[h]]
              )
            )
            # add row to mdr
            outmdr <- data.table::rbindlist(list(
              outmdr,
              append_row
            ),
            fill = T)
          }
        }
      }
    } else {
      DIZtools::feedback(
        print_this = paste0("Ignoring", element_id, ". No 'dqa'-slot present"),
        findme = "61aa00fdf7",
        logfile_dir = logfile_dir,
        headless = headless
      )
    }
  }
  # change order of columns for better comparability
  neworder <- c("designation", "source_variable_name", "source_table_name",
                "filter", "source_system_name", "source_system_type",
                "restricting_date_var", "restricting_date_format", "key",
                "variable_name", "fhir", "variable_type", "constraints",
                "value_threshold", "missing_threshold", "dqa_assessment",
                "definition", "sql_from", "sql_join_on", "sql_join_type",
                "sql_where", "data_map", "plausibility_relation")

  check_missing_columns <- setdiff(neworder, colnames(outmdr))

  if (length(check_missing_columns) > 0) {
    for (mc in check_missing_columns) {
      outmdr[, (mc) := NA]
    }
  }
  # set new order
  data.table::setcolorder(outmdr, neworder)
  outmdr <- outmdr[!duplicated(outmdr), ]
  return(outmdr)
}


transform_data_types <- function(type) {
  # TODO numeric is not implemented
  if (type == "DATE") {
    outdat <- "calendar"
  } else if (type == "INTEGER") {
    outdat <- "integer"
  } else if (type == "enumerated") {
    outdat <- "permittedValues"
  } else if (type == "STRING") {
    outdat <- "string"
  } else {
    outdat <- "test"
  }
  return(outdat)
}
