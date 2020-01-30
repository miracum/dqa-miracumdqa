button_mdr <- function(utils_path, mdr_filename) {

  shiny::withProgress(message = "Loading MDR", value = 0, {
    incProgress(
      1 / 1,
      detail = "... from MIRACUM Samply.MDR ...")
    # read MDR
    mdr <- mdr_from_samply(headless = FALSE)
  })
  return(mdr)
}


button_send_datamap <- function(rv) {
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
      lapply(rv$datamap, function(x) {
        unname(split(x, seq_len(nrow(x))))
      })
    ))

  # https://stackoverflow.com/questions/27650331/adding-an-email-
  # button-in-shiny-using-tabletools-or-otherwise
  # https://stackoverflow.com/questions/37795760/r-shiny-add-
  # weblink-to-actionbutton
  # https://stackoverflow.com/questions/45880437/r-shiny-use-onclick-
  # option-of-actionbutton-on-the-server-side
  # https://stackoverflow.com/questions/45376976/use-actionbutton-to-
  # send-email-in-rshiny

  return(paste0(
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
  ))
}
