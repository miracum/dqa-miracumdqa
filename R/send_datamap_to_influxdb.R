require(influxdbr)

#' @title send_datamap_to_influx
#'
#' @param rv The global rv object. Only the rv$datamap part will be used.
#'
#' @export
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
    if (isTRUE(rv$datamap$exported2influx)) {
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

          # Set up the connection
          con <- influx_connection(host = "influxdb")

          # write example data.frame to database
          influx_write(
            con = con,
            db = "mydb",
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
          showNotification("\U2714 Datamap successfully exported")
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
