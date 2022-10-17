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

button_mdr <-
  function(utils_path,
           mdr_filename,
           logfile_dir,
           headless) {
    DIZtools::feedback(print_this = "Loading the metadata repository",
                       logfile_dir = logfile_dir,
                       findme = "8dff6a2009",
                       headless = headless)
    shiny::withProgress(message = "Loading MDR", value = 0, {

      # read MDR

      tryCatch(
        expr = {

          # cache path
          mdr_cache_path <- file.path(tempdir(), "dqa_mdr_cache.csv")

          # get timestamp of cached mdr
          if (file.exists(mdr_cache_path)) {
            date_cache_created <- file.info(mdr_cache_path)$ctime %>%
              as.Date()

            if ((as.Date(Sys.time()) - date_cache_created) == 0) {
              # go with cached mdr
              load_mdr <- FALSE
            } else {
              # load new version, if cache is not from same day
              load_mdr <- TRUE
            }
          } else {
            # if no cache exists, load new mdr
            load_mdr <- TRUE
          }

          # if a new mdr is required from
          if (isTRUE(load_mdr)) {

            shiny::incProgress(
              2 / 3,
              detail = "... from DEHUB-MDR ..."
            )
            DIZtools::feedback(
              print_this = "Trying to load MDR from DEHUB-MDR rest API",
              findme = "762de006ae")
            # for debugging
            #% stop()
            base_url <- Sys.getenv("MDR_BASEURL")
            namespace <- Sys.getenv("MDR_NAMESPACE")

            delay_load <- ifelse(
              reticulate::py_module_available("dqa_mdr_connector"),
              FALSE,
              TRUE
            )

            # get dqa GetMDR-class
            dqa_connector <- reticulate::import(
              "dqa_mdr_connector.get_mdr",
              delay_load = delay_load
            )

            # get list of dataelements to be downloaded from mdr
            de_fhir_path_list <- reticulate::import_from_path(
              "dqamdr_config",
              path = system.file("application/_utilities/MDR/",
                                 package = "miRacumDQA")
            )$de_fhir_path_list

            dqa_con <- dqa_connector$GetMDR(
              output_folder = tempdir(),
              output_filename = "mdr.csv",
              de_fhir_paths = de_fhir_path_list,
              api_url = base_url,
              bypass_auth = TRUE,
              namespace_designation = namespace,
              return_csv = FALSE
            )

            mdr <- dqa_con() %>%
              data.table::data.table()

            mdr[mdr == ""] <- NA

            # save MDR cache file
            data.table::fwrite(
              x = mdr,
              file = mdr_cache_path
            )

            if (nrow(mdr) < 2) {
              stop("\nMDR loaded from DEHUB has less than 2 rows...\n")
            }

            DIZtools::feedback(
              print_this = "Loaded MDR from DEHUB-MDR rest API",
              findme = "5cc7a8517b"
            )

            sqls <- dqa_con$sql_statements

            if (length(sqls) > 0) {
              DIZtools::feedback(
                print_this = "Loaded SQLs from DEHUB-MDR rest API",
                findme = "5cc7f8517b"
              )
            } else {
              sqls <- NULL
            }


          } else {
            shiny::incProgress(
              1,
              detail = "... from local cache ..."
            )
          }
          # always read from local file in order to apply rules from that
          # function
          mdr <- DQAstats::read_mdr(
            mdr_filename = mdr_cache_path
          )
        }, error = function(e) {
          shiny::incProgress(
            1,
            detail = "... from local file ..."
          )
          DIZtools::feedback(
            print_this =
              paste0("Fallback to load MDR from local file. Reason: ",
                     e),
            type = "Warning",
            findme = "ab733c2b51"
          )
          mdr <- DQAstats::read_mdr( # nolint
            utils_path = utils_path,
            mdr_filename = "mdr.csv"
          )

          sqls <- NULL # nolint
        }
      )

      # and uncomment the 2 lines below. Doing this, you don't need to
      # switch to DQAgui for testing local changes. However, you still need
      # to "Install and Restart" miRacumDQA!

      # # start nolint
      # mdr <- DQAstats::read_mdr(utils_path = utils_path,
      #                          mdr_filename = "mdr.csv")
      # end nolint
    })
    return(list("mdr" = mdr, "sqls" = sqls))
  }

#' @title button_send_datamap
#' @description This function is an exporte wrapper around the actual function
#'   to send the datamap. This actual function can be customized by the user.
#'
#' @param rv The global rv object. rv$datamap needs to be valid.
#'
#' @export
button_send_datamap <- function(rv) {
  DIZtools::feedback(
    print_this = "Sending the datamap",
    logfile_dir = rv$log$logfile_dir,
    headless = rv$headless
  )
  send_datamap_to_influx(rv)
}


#' @title send_datamap_to_influx
#' @description This function loads the datamap from the rv-object and sends
#'   it to an influxdb server. The credentials will be loaded from the
#'   config_file also stored in the rv-object.
#'   If the export was successfull, rv$datamap$exported will be set to TRUE.
#'
#' @param rv The global rv object. rv$datamap and rv$config_file need to
#'   be valid.
#'
send_datamap_to_influx <- function(rv) {
  if (isTRUE(is.null(rv$datamap$target_data))) {
    DIZtools::feedback(
      print_this = paste0("While exporting: datamap --> influxdb: ",
                          "datamap is empty"),
      findme = "c51c05eeea",
      type = "Error",
      logfile_dir = rv$log$logfile_dir,
      headless = rv$headless
    )
  } else {
    if (isTRUE(rv$datamap$exported)) {
      DIZtools::feedback(
        "The datamap was already exported. Skipping.",
        findme = "3fd547ccbf",
        logfile_dir = rv$log$logfile_dir,
        headless = rv$headless
      )
    } else {
      # Not exported yet so start it now:
      # Assign the data
      site <- rv$sitename
      system <- rv$target$system_name

      if (isTRUE(is.null(site) ||
                 # is.null(item) ||
                 is.null(rv$datamap$target_data[, "n"]) ||
                 is.null(system))) {
        DIZtools::feedback(
          "One of the inputs for influxdb-export isn't valid.",
          findme = "1bb38be44b",
          logfile_dir = rv$log$logfile_dir,
          headless = rv$headless
        )
      } else {
        tryCatch({
          ## If the data-table crashes, or (and this is more likely) the
          ## connection to the influxdb can't be established,
          ## it throws an error:

          # Assign the data to one single dataframe for export
          dm <- data.table::copy(rv$datamap$target_data)

          ## Convert all cols to strings (except the 'n' column):
          cols <- names(dm)
          cols <- cols[cols != "n"]
          dm[, lapply(.SD, as.character), .SDcols = cols]

          ## Add the site and system to the datamap:
          dm[, ("site") := site]
          dm[, ("system") := system]

          ## Add another column with specific names:
          dm[get("variable") == "Patientennummer" |
               get("variable") == "Patienten-Identifikator",
             "lay_term" := "Patienten"]
          dm[get("variable") == "Fallnummer" |
               get("variable") == "Aufnahmenummer",
             "lay_term" := "F\u00E4lle"]
          dm[get("variable") == "Laborwerte (LOINC)",
             "lay_term" := "Laborwerte"]
          dm[get("variable") == "Hauptdiagnosen (ICD)" |
               get("variable") == "VollstaendigerDiagnosekode",
             "lay_term" := "Diagnosen"]
          dm[get("variable") == "Nebendiagnosen (ICD)",
             "lay_term" := "Nebendiagnosen"]
          dm[get("variable") == "Prozeduren (OPS)",
             "lay_term" := "Prozeduren"]
          dm[get("variable") == "Medikation (OPS)",
             "lay_term" := "Medikation"]

          ## Rename "variable" --> "item":
          data.table::setnames(
            x = dm,
            old = "variable",
            new = "item"
          )

          # The column "n" needs to be of type integer:
          dm[, "n" := as.integer(get("n"))]

          ## Keep only the tag cols (and 'n'):
          tag_cols <- c("site", "system", "item", "lay_term")
          dm <- dm[, .SD, .SDcols = c(tag_cols, "n")]

          ## Remove rows with NA as lay_terms:
          DIZtools::feedback(
            print_this = paste0(
              "Removing rows '",
              paste(dm[is.na(get("lay_term")), "item"], collapse = "', '"),
              "' because these don't have a lay_term specified."
            ),
            findme = "d66b56d255",
            logfile_dir = rv$log$logfile_dir,
            headless = rv$headless
          )
          dm <- dm[!is.na(get("lay_term")), ]

          # Set up the connection:
          con_res <- get_influx_connection(rv)

          # write example data.frame to database
          influxdbr::influx_write(
            con = con_res$con,
            db = con_res$config$dbname,
            x = dm,
            tag_cols = tag_cols,
            #% tag_cols = c("site", "system", "item", "n"),
            measurement = "item_counts"
          )

          # Set flag that the data was already exportet to avoid duplicates:
          rv$datamap$exported <- TRUE

          # Console feedback:
          DIZtools::feedback(
            paste0(
              "Successfully finished export:",
              " datamap --> influxdb for elements '",
              paste(unique(dm[["lay_term"]]), collapse = "', '"),
              "'."
            ),
            findme = "a087e237e5",
            logfile_dir = rv$log$logfile_dir,
            headless = rv$headless
          )
          # GUI feedback:
          if (isFALSE(rv$headless)) {
            shiny::showNotification("\U2714 Datamap successfully exported",
                                    type = "message",
                                    duration = 10)
          }
          rm(dm)
        },
        error = function(cond) {
          # Console feedback:
          DIZtools::feedback(
            paste0("While exporting: datamap --> influxdb: ", cond),
            findme = "5ba89e3577",
            type = "Error",
            logfile_dir = rv$log$logfile_dir,
            headless = rv$headless
          )
          # GUI feedback:
          if (isFALSE(rv$headless)) {
            shiny::showNotification(
              paste0(
                "\U2716 Error while exporting the Datamap.",
                " See the logfile for more information."
              ),
              type = "error",
              duration = 10
            )
          }
        }
        )
      }
    }
  }
}

#' @title get_influx_connection
#' @description This function loads the datamap from the rv-object and sends
#'   it to an influxdb server. The credentials will be loaded from the
#'   config_file also stored in the rv-object.
#'   If the export was successfull, rv$datamap$exported will be set to TRUE.
#'
#' @param rv The global rv object. Only the rv$config_file part will be used.
#'
#' @return Returns a list with elements result$con (The connection to influxdb)
#'   and result$config (The config credentials extracted from the rv-object).
#'
get_influx_connection <- function(rv) {
  config <- list()

  config$host <- Sys.getenv("INFLUX_HOST")
  config$password <- Sys.getenv("INFLUX_PASSWORD")
  config$user <- Sys.getenv("INFLUX_USER")
  config$port <- Sys.getenv("INFLUX_PORT")
  config$dbname <- Sys.getenv("INFLUX_DBNAME")
  config$scheme <- Sys.getenv("INFLUX_SCHEME")
  config$path <- Sys.getenv("INFLUX_PATH")

  if (isTRUE(
    is.null(config$scheme) || is.null(config$dbname) ||
    is.null(config$host) ||
    is.null(config$port) || is.null(config$path)
  )) {
    DIZtools::feedback(
      paste0(
        "One or more of the necessary input parameters out of ",
        "config_file for influxdb connection is missing."
      ),
      findme = "9e673f0d8a",
      type = "Error",
      logfile_dir = rv$log$logfile_dir,
      headless = rv$headless
    )
    stop()
  } else {
    if (isTRUE(is.null(config$user) || config$user == "")) {
      # There is no username --> Authentification seems to be disabled
      DIZtools::feedback(
        paste0(
          "There is no username in the config_file. ",
          "Trying to connect without authentification."
        ),
        findme = "9a01a5ce12",
        logfile_dir = rv$log$logfile_dir,
        headless = rv$headless
      )

      con <-
        influxdbr::influx_connection(
          scheme = config$scheme,
          host = config$host,
          port = config$port,
          path = config$path,
          verbose = TRUE
        )

      DIZtools::feedback(
        "Connection established",
        findme = "77dc31289f",
        logfile_dir = rv$log$logfile_dir,
        headless = rv$headless
      )

    } else {
      # Authentification seems to be enabled so use username & password:
      DIZtools::feedback(
        paste0(
          "There is a username in the config_file. ",
          "Trying to connect with authentification."
        ),
        findme = "accface388",
        logfile_dir = rv$log$logfile_dir,
        headless = rv$headless
      )

      con <-
        influxdbr::influx_connection(
          scheme = config$scheme,
          host = config$host,
          port = config$port,
          user = config$user,
          pass = config$password,
          path = config$path,
          verbose = TRUE
        )
      DIZtools::feedback(
        "Connection established",
        findme = "d408ca173a",
        logfile_dir = rv$log$logfile_dir,
        headless = rv$headless
      )
    }
  }
  return(list("con" = con,
              "config" = config))
}
