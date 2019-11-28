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

mdr_from_samply <- function(base_url = "https://mdr.miracum.de/rest/api/mdr/",
                            namespace = "dqa",
                            master_system_type = "csv",
                            master_system_name = "p21csv") {

  #% base_url = "https://mdr.miracum.de/rest/api/mdr/"
  #% namespace = "dqa"
  #% master_system_type = "csv"
  #% master_system_name = "p21csv"

  stopifnot(
    is.character(namespace),
    namespace == "dqa",
    is.character(master_system_type),
    master_system_type == "csv",
    is.character(master_system_name),
    master_system_name == "p21csv"
  )

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
    cat("\nDataelement URL: ", dataelement_url, "\n")

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
      if (sys == master_system_name)
      # in a first level, extract our master_slot row
      csv_slot <- jsonlite::fromJSON(
        txt = dqa_slot$csv[[master_system_name]]
      )
      append_row <- cbind(
        append_basis,
        data.table::as.data.table(
          csv_slot
        )
      )
    }

    # add master row to mdr
    outmdr <- data.table::rbindlist(list(
      outmdr,
      append_row
    ),
    fill = T)

    # TODO postgres slot hard-coded
    for (sys in names(dqa_slot$postgres)) {
      postgres_slot <- jsonlite::fromJSON(
        txt = dqa_slot$postgres[[sys]]
      )
      append_row <- cbind(
        append_basis,
        data.table::as.data.table(
          postgres_slot$base
        )
      )
      # add row to mdr
      outmdr <- data.table::rbindlist(list(
        outmdr,
        append_row
      ),
      fill = T)

      if (!is.null(postgres_slot$helper_vars)) {
        append_row <- cbind(
          append_basis,
          data.table::as.data.table(
            postgres_slot$helper_vars
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
