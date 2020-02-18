button_mdr <- function(utils_path, mdr_filename) {
  shiny::withProgress(message = "Loading MDR", value = 0, {
    incProgress(1 / 1,
                detail = "... from MIRACUM Samply.MDR ...")
    # read MDR
    mdr <- mdr_from_samply(headless = FALSE)
  })
  return(mdr)
}

button_send_datamap <- function(rv) {
  return(send_datamap_to_influx(rv))
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
    DQAgui::feedback(
      paste0("While exporting: datamap --> influxdb: ",
             "datamap is empty"),
      findme = "c51c05eeea",
      type = "Error"
    )
  } else {
    if (isTRUE(rv$datamap$exported)) {
      DQAgui::feedback("The datamap was already exported. Skipping.",
                       findme = "3fd547ccbf")
    } else {
      # Not exported yet so start it now:
      # Assign the data
      site <- rv$sitename
      system <- rv$target$system_name
      item <- rv$datamap$target_data[, "variable"]
      n <- rv$datamap$target_data[, "n"]

      # The column "variable" needs to be renamed to "item" for influxdb:
      names(item)[names(item) == "variable"] <- "item"

      if (isTRUE(is.null(site) ||
                 is.null(item) ||
                 is.null(n) ||
                 is.null(system))) {
        DQAgui::feedback("One of the inputs for influxdb-export isn't valid.",
                         findme = "1bb38be44b")
      } else {
        tryCatch({
          ## If the data-frame crashes, or (and this is more likely) the
          ## connection to the influxdb can't be established,
          ## it throws an error:

          # Assign the data to one single dataframe for export
          datamap <-
            data.frame(site, system, item, n, stringsAsFactors = FALSE)

          # The column "n" needs to be of type integer:
          datamap$n <- as.integer(datamap$n)
          str(datamap)

          # Set up the connection:
          # Port, Scheme and other settings are defaults here and therefore
          # not explicitely defined but can be modified in
          # influx_connection(...):
          # con <- influx_connection(host = "influxdb", verbose = T)
          con_res <- get_influx_connection(rv)

          # write example data.frame to database
          influxdbr::influx_write(
            con = con_res$con,
            db = con_res$config$dbname,
            x = datamap,
            tag_cols = c("site", "system", "item"),
            measurement = "item_counts"
          )

          # Set flag that the data was already exportet to avoid duplicates:
          rv$datamap$exported <- T

          # Console feedback:
          DQAgui::feedback(paste0(
            "Successfully finished export: ",
            "datamap --> influxdb."
          ),
          findme = "a087e237e5")
          # GUI feedback:
          showNotification(
            "\U2714 Datamap successfully exported",
            type = "message",
            duration = 10
          )
        },
        error = function(cond) {
          # Console feedback:
          DQAgui::feedback(
            paste0("While exporting: datamap --> influxdb: ", cond),
            findme = "5ba89e3577",
            type = "Error"
          )
          # GUI feedback:
          showNotification(
            "\U2716 Error while exporting the Datamap.",
            type = "error",
            duration = 10
          )
        },
        warning = function(cond) {
          # Console feedback:
          DQAgui::feedback(
            paste0("While exporting: datamap --> influxdb: ", cond),
            findme = "010f0daea3",
            type = "Warning"
          )
          # GUI feedback:
          showNotification(
            "\U2716 Error while exporting the Datamap.",
            type = "error",
            duration = 10
          )
        })
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

  config <-
    DQAstats::get_config(config_file = rv$config_file, config_key = "influxdb")

  if (isTRUE(rv$use_env_credentials)) {
    config$host <- Sys.getenv("INFLUX_HOST")
    config$password <- Sys.getenv("INFLUX_PASSWORD")
  }

  if (isTRUE(is.null(config$scheme) || is.null(config$dbname) ||
             is.null(config$host) || is.null(config$port) || is.null(config$path) )) {
    DQAgui::feedback(
      paste0(
        "One or more of the necessary input parameters out of ",
        "config_file for influxdb connection is missing."
      ),
      findme = "9e673f0d8a",
      type = "Error"
    )
    stop()
  } else {
    if (isTRUE(is.null(config$user) || config$user == "")) {
      # There is no username --> Authentification seems to be disabled
      DQAgui::feedback(
        paste0(
          "There is no username in the config_file. ",
          "Trying to connect without authentification."
        ),
        findme = "9a01a5ce12",
      )

      con <-
        influxdbr::influx_connection(
          scheme = config$scheme,
          host = config$host,
          port = config$port,
          path = config$path,
          verbose = T
        )

      DQAgui::feedback("Connection established", findme = "77dc31289f")

    } else {
      # Authentification seems to be enabled so use username & password:
      DQAgui::feedback(
        paste0(
          "There is a username in the config_file. ",
          "Trying to connect with authentification."
        ),
        findme = "accface388",
      )

      con <-
        influxdbr::influx_connection(
          scheme = config$scheme,
          host = config$host,
          port = config$port,
          user = config$user,
          pass = config$password,
          path = config$path,
          verbose = T
        )
      DQAgui::feedback("Connection established", findme = "d408ca173a")
    }
  }
  return(list("con" = con,
              "config" = config))
}
