button_mdr <-
  function(utils_path,
           mdr_filename,
           logfile_dir,
           headless) {
    DIZutils::feedback(print_this = "Loading the metadata repository",
                       logfile_dir = logfile_dir,
                       headless = headless)
    shiny::withProgress(message = "Loading MDR", value = 0, {

      # read MDR

      mdr <- tryCatch(
        expr = {
          incProgress(
            1,
            detail = "... from Samply.MDR ..."
          )
          base_url <- Sys.getenv("MDR_BASEURL")
          namespace <- Sys.getenv("MDR_NAMESPACE")
          mdr <- mdr_from_samply(
            base_url = base_url,
            namespace = namespace,
            headless = headless,
            logfile_dir = logfile_dir
          )
          DIZutils::feedback(
            print_this = "Loading MDR from Samply.MDR web API",
            logfile_dir = logfile_dir,
            headless = headless
          )
          mdr
        }, error = function(e) {
          incProgress(
            1,
            detail = "... from local file ..."
          )
          DIZutils::feedback(
            print_this = "Fallback to load MDR from local file",
            logfile_dir = logfile_dir,
            headless = headless
          )
          mdr <- DQAstats::read_mdr(
            utils_path = utils_path,
            mdr_filename = "mdr.csv"
          )
          mdr
        }, finally = function(f) {
          return(mdr)
        }
      )

      # For debugging: just comment the lines above (mdr_from_samply)
      # and uncomment the 2 lines below. Doing this, you don't need to
      # switch to DQAgui for testing local changes. However, you still need
      # to "Install and Restart" miRacumDQA!

      # # start nolint
      # mdr <- DQAstats::read_mdr(utils_path = utils_path,
      #                          mdr_filename = "mdr.csv")
      # end nolint
    })
    return(mdr)
  }

#' @title button_send_datamap
#' @description This function is an exporte wrapper around the actual function
#'   to send the datamap. This actual function can be customized by the user.
#'
#' @param rv The global rv object. rv$datamap needs to be valid.
#'
#' @export
button_send_datamap <- function(rv) {
  DIZutils::feedback(
    print_this = "Sending the datamap",
    logfile_dir = rv$log$logfile_dir,
    headless = rv$headless
  )
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
    DIZutils::feedback(
      paste0("While exporting: datamap --> influxdb: ",
             "datamap is empty"),
      findme = "c51c05eeea",
      type = "Error",
      logfile_dir = rv$log$logfile_dir,
      headless = rv$headless
    )
  } else {
    if (isTRUE(rv$datamap$exported)) {
      DIZutils::feedback(
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
        DIZutils::feedback(
          "One of the inputs for influxdb-export isn't valid.",
          findme = "1bb38be44b",
          logfile_dir = rv$log$logfile_dir,
          headless = rv$headless
        )
      } else {
        tryCatch({
          ## If the data-frame crashes, or (and this is more likely) the
          ## connection to the influxdb can't be established,
          ## it throws an error:

          # Assign the data to one single dataframe for export
          datamap <- data.frame(site,
                                system,
                                item,
                                lay_term,
                                n,
                                stringsAsFactors = FALSE)

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
          DIZutils::feedback(
            paste0(
              "Successfully finished export:",
              " datamap --> influxdb."
            ),
            findme = "a087e237e5",
            logfile_dir = rv$log$logfile_dir,
            headless = rv$headless
          )
          # GUI feedback:
          showNotification(
            "\U2714 Datamap successfully exported",
            type = "message",
            duration = 10
          )
        },
        error = function(cond) {
          # Console feedback:
          DIZutils::feedback(
            paste0("While exporting: datamap --> influxdb: ", cond),
            findme = "5ba89e3577",
            type = "Error",
            logfile_dir = rv$log$logfile_dir,
            headless = rv$headless
          )
          # GUI feedback:
          showNotification(
            paste0(
              "\U2716 Error while exporting the Datamap.",
              " See the logfile for more information."
            ),
            type = "error",
            duration = 10
          )
        },
        warning = function(cond) {
          # Console feedback:
          DIZutils::feedback(
            paste0("While exporting: datamap --> influxdb: ", cond),
            findme = "010f0daea3",
            type = "Warning",
            logfile_dir = rv$log$logfile_dir,
            headless = rv$headless
          )
          # GUI feedback:
          showNotification(
            paste0(
              "\U2716 Warning while exporting the Datamap.",
              " See the logfile for more information."
            ),
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
    DIZutils::feedback(
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
      DIZutils::feedback(
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
          verbose = T
        )

      DIZutils::feedback(
        "Connection established",
        findme = "77dc31289f",
        logfile_dir = rv$log$logfile_dir,
        headless = rv$headless
      )

    } else {
      # Authentification seems to be enabled so use username & password:
      DIZutils::feedback(
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
          verbose = T
        )
      DIZutils::feedback(
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
