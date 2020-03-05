button_mdr <- function(utils_path, mdr_filename) {
  shiny::withProgress(message = "Loading MDR", value = 0, {
    incProgress(1 / 1,
                detail = "... from MIRACUM Samply.MDR ...")
    # read MDR
    mdr <- mdr_from_samply(headless = FALSE)

    # For debugging: just comment the line above (mdr_from_samply)
    # and uncomment the 2 lines below. Doing this, you don't need to
    # switch to DQAgui for testing local changes. However, you still need
    # to "Install and Restart" miRacumDQA!

    # mdr <- DQAstats::read_mdr(utils_path = utils_path,
    #                           mdr_filename = "mdr.csv")

  })
  return(mdr)
}

#' @title button_send_datamap
#' @description This function is an exporte wrapper around the actual function
#'   to send the datamap. This actual function can be customized by the user.
#'
#' @param rv The global rv object. rv$datamap and rv$config_file need to
#'   be valid.
#'
#' @export
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
    DQAstats::feedback(
      paste0("While exporting: datamap --> influxdb: ",
             "datamap is empty"),
      findme = "c51c05eeea",
      type = "Error"
    )
  } else {
    if (isTRUE(rv$datamap$exported)) {
      DQAstats::feedback("The datamap was already exported. Skipping.",
                       findme = "3fd547ccbf")
    } else {
      # Not exported yet so start it now:
      # Assign the data
      site <- rv$sitename
      system <- rv$target$system_name
      item <- rv$datamap$target_data[, "variable", with = F]

      # TODO datamap mappings for the symposium
      lay_term <- rv$datamap$target_data[, "variable", with = F]
      lay_term[get("variable") == "Patientennummer",
               ("variable") := "Patienten"]
      lay_term[get("variable") == "Fallnummer",
               ("variable") := "F\u00E4lle"]
      lay_term[get("variable") == "Laborwerte (LOINC)",
               ("variable") := "Laborwerte"]
      lay_term[get("variable") == "Diagnosen (ICD)",
               ("variable") := "Diagnosen"]
      lay_term[get("variable") == "Prozeduren (OPS)",
               ("variable") := "Prozeduren"]

      n <- rv$datamap$target_data[, "n", with = F]

      # The column "variable" needs to be renamed to "item" for influxdb:
      colnames(item) <- "item"
      colnames(lay_term) <- "lay_term"

      if (isTRUE(is.null(site) ||
                 is.null(item) ||
                 is.null(n) ||
                 is.null(system))) {
        DQAstats::feedback("One of the inputs for influxdb-export isn't valid.",
                         findme = "1bb38be44b")
      } else {
        tryCatch({
          ## If the data-frame crashes, or (and this is more likely) the
          ## connection to the influxdb can't be established,
          ## it throws an error:

          # Assign the data to one single dataframe for export
          datamap <- data.frame(
              site,
              system,
              item,
              lay_term,
              n,
              stringsAsFactors = FALSE
              )

          # The column "n" needs to be of type integer:
          datamap$n <- as.integer(datamap$n)

          print(datamap)

          # Set up the connection:
          con_res <- get_influx_connection(rv)

          # write example data.frame to database
          influxdbr::influx_write(
            con = con_res$con,
            db = con_res$config$dbname,
            x = datamap,
            tag_cols = c("site", "system", "item", "lay_term"),
            # tag_cols = c("site", "system", "item", "n"),
            measurement = "item_counts"
          )

          # Set flag that the data was already exportet to avoid duplicates:
          rv$datamap$exported <- TRUE

          # Console feedback:
          DQAstats::feedback(paste0(
            "Successfully finished export:",
            " datamap --> influxdb."
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
          DQAstats::feedback(
            paste0("While exporting: datamap --> influxdb: ", cond),
            findme = "5ba89e3577",
            type = "Error"
          )
          # GUI feedback:
          showNotification(
            paste0("\U2716 Error while exporting the Datamap.",
                   " See the logfile for more information."),
            type = "error",
            duration = 10
          )
        },
        warning = function(cond) {
          # Console feedback:
          DQAstats::feedback(
            paste0("While exporting: datamap --> influxdb: ", cond),
            findme = "010f0daea3",
            type = "Warning"
          )
          # GUI feedback:
          showNotification(
            paste0("\U2716 Warning while exporting the Datamap.",
                   " See the logfile for more information."),
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

  if (isTRUE(
    is.null(config$scheme) || is.null(config$dbname) ||
    is.null(config$host) ||
    is.null(config$port) || is.null(config$path)
  )) {
    DQAstats::feedback(
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
      DQAstats::feedback(
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

      DQAstats::feedback("Connection established", findme = "77dc31289f")

    } else {
      # Authentification seems to be enabled so use username & password:
      DQAstats::feedback(
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
      DQAstats::feedback("Connection established", findme = "d408ca173a")
    }
  }
  return(list("con" = con,
              "config" = config))
}
