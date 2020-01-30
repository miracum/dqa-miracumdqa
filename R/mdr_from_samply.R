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
mdr_from_samply <- function(base_url = "https://mdr.miracum.de/rest/api/mdr/",
                            namespace = "dqa",
                            master_system_type = "csv",
                            master_system_name = "p21csv",
                            headless = TRUE) {

  stopifnot(
    is.character(namespace),
    is.character(master_system_type),
    master_system_type == "csv",
    is.character(master_system_name),
    master_system_name == "p21csv"
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
  base_url <- DQAstats::clean_path_name(base_url)

  # set members url
  member_url <- paste0(
    base_url,
    "namespaces/",
    namespace,
    "/members"
  )
  cat("\nMember URL: ", member_url, "\n")

  # get namespace members
  response_members <- jsonlite::fromJSON(
    txt = member_url
  )
  # namespace must have exactly 1 member --> dqa
  stopifnot(nrow(response_members$results) == 1,
            !is.null(response_members$results$id))

  # set dataelement-groups url
  groupmember_url <- paste0(
    base_url,
    "dataelementgroups/",
    response_members$results$id,
    "/members"
  )
  cat("\nGroup-member URL: ", groupmember_url, "\n")

  # get group members
  response_group <- jsonlite::fromJSON(
    txt = groupmember_url
  )
  # transform results to data.table
  response_group$results <- data.table::as.data.table(
    response_group$results
  )

  # initialize empty data.table to store mdr
  outmdr <- data.table::data.table()

  # loop over all dataelement-ids
  for (element_id in response_group$results$id) {

    # set dataelement url
    dataelement_url <- paste0(
      base_url,
      "dataelements/",
      element_id
    )

    msg <- paste("Dataelement URL:", dataelement_url)
    message("", msg, "\n")
    if (isFALSE(headless)) {
      shinyjs::logjs(msg)
      # Increment the progress bar, and update the detail text.
      progress$inc(
        1 / length(response_group$results$id),
        detail = paste("reading", dataelement_url))
    }

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
    dqa_slot <- tryCatch(
      expr = {
        outdat <- jsonlite::fromJSON(
          txt = response_dataelement$slots[get("slot_name") == "dqa",
                                           get("slot_value")]
        )
        outdat
      }, error = function(e) {
        print(e)
        outdat <- NULL
        outdat
      }, finally = function(f) {
        return(outdat)
      }
    )

    if (is.null(dqa_slot)) {
      # if there is no dqa slot, the dataelement is
      # not interesting for us
      next
    }

    # TODO csv slot hard-coded
    stopifnot(length(dqa_slot$csv) > 0)
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

    # TODO postgres slot hard-coded
    stopifnot(length(dqa_slot$postgres) > 0)
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
  }
  # change order of columns for better comparability
  neworder <- c("designation", "source_variable_name", "source_table_name",
                "filter",
                "source_system_name", "source_system_type", "key",
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
  }
  return(outdat)
}
