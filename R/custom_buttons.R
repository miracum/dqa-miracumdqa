require(influxdbr)

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
  #% return(send_datamap_to_mail(rv))
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

          # Set up the connection:
          # Port, Scheme and other settings are defaults here and therefore
          # not explicitely defined but can be modified in
          # influx_connection(...):
          # con <- influx_connection(host = "influxdb", verbose = T)
          con_res <- get_influx_connection(rv)

          # write example data.frame to database
          influx_write(
            con = con_res$con,
            db = con_res$config$dbname,
            x = datamap,
            tag_cols = c("site", "system", "variable"),
            # item = variable
            measurement = "item_count"
          )

          # Set flag that the data was already exportet to avoid duplicates:
          rv$datamap$exported <- T

          DQAgui::feedback(paste0(
            "Successfully finished export: ",
            "datamap --> influxdb."
          ),
          findme = "a087e237e5")
          showNotification(
            "\U2714 Datamap successfully exported",
            type = "message",
            duration = 10
          )
        },
        error = function(cond) {
          DQAgui::feedback(
            paste0("While exporting: datamap --> influxdb: ", cond),
            findme = "5ba89e3577",
            type = "Error"
          )
        },
        warning = function(cond) {
          DQAgui::feedback(
            paste0("While exporting: datamap --> influxdb: ", cond),
            findme = "010f0daea3",
            type = "Warning"
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

  if (isTRUE(is.null(config$dbname) ||
             is.null(config$host) || is.null(config$port))) {
    DQAgui::feedback(
      paste0(
        "One or more of these are not set in ",
        "config_file for influxdb: dbname, host, port."
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
        influx_connection(host = config$host,
                          port = config$port,
                          verbose = T)

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
        influx_connection(
          host = config$host,
          port = config$port,
          user = config$user,
          pass = config$pass,
          verbose = T
        )
      DQAgui::feedback("Connection established", findme = "d408ca173a")
    }
  }
  return(list("con" = con,
              "config" = config))
}

send_datamap_to_mail <- function(rv) {
  # encode datamap to json string
  json_string <-
    jsonlite::toJSON(c(
      list(
        "sitename" = rv$sitename,
        "lastrun" = as.character(rv$end_time),
        "run_duration" = as.character(round(rv$duration, 2)),
        "version_dqastats" = as.character(utils::packageVersion("DQAstats")),
        "version_dqagui" = as.character(utils::packageVersion("DQAgui"))
      ),
      rv$datamap$target_data
    ))

  # https://stackoverflow.com/questions/27650331/adding-an-email-
  # button-in-shiny-using-tabletools-or-otherwise
  # https://stackoverflow.com/questions/37795760/r-shiny-add-
  # weblink-to-actionbutton
  # https://stackoverflow.com/questions/45880437/r-shiny-use-onclick-
  # option-of-actionbutton-on-the-server-side
  # https://stackoverflow.com/questions/45376976/use-actionbutton-to-
  # send-email-in-rshiny

  return(
    paste0(
      "window.open('mailto:",
      rv$datamap_email,
      "?",
      "body=",
      utils::URLencode(
        paste0(
          "Site name: ",
          rv$sitename,
          "\n\n(this is an automatically created email)\n\n",
          "\n\nLast run: ",
          rv$end_time,
          "\nRun duration: ",
          round(rv$duration, 2),
          " min.",
          "\n\nDatamap (JSON):\n",
          json_string
        )
      ),
      "&subject=",
      paste0("Data Map - ", rv$sitename),
      "')"
    )
  )
}
