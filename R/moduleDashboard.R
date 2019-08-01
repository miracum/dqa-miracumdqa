# miRacumDQA - The MIRACUM consortium's data quality assessment tool.
# Copyright (C) 2019 MIRACUM - Medical Informatics in Research and Medicine
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

#' @title moduleDashboardServer
#'
#' @param input Shiny server input object
#' @param output Shiny server output object
#' @param session Shiny session object
#' @param rv The global 'reactiveValues()' object, defined in server.R
#' @param input_re The Shiny server input object, wrapped into a reactive expression: input_re = reactive({input})
#'
#' @export
#'
# moduleDashboardServer
moduleDashboardServer <- function(input, output, session, rv, input_re){

  # initialize some reactive stuff here
  observe({
    if (is.null(rv$dash_summary_source)){
      rv$dash_summary_source <- summaryTable()
    }
    if (is.null(rv$dash_summary_target)){
      rv$dash_summary_target <- summaryTable()
    }
  })
  output$dash_instruction <- renderText({
    paste0("Please configure and test your database connection in the settings tab.\nThen return here in order to load the data.")
  })

  observeEvent(input_re()[["moduleDashboard-dash_load_btn"]], {

    # set start.time, when clicking the button
    rv$start.time <- format(Sys.time(), usetz = T, tz = "CET")

    # check database connection
    rv$db_con <- testDBcon(rv$db_settings)

    # check if sitename is present
    if (nchar(input_re()[["moduleConfig-config_sitename"]]) < 2 || any(grepl("\\s", input_re()[["moduleConfig-config_sitename"]]))){
      shiny::showModal(modalDialog(
        title = "Invalid values",
        "No empty strings or spaces allowed in the site name configuration."
      ))
      rv$sql <- NULL
    } else {
      rv$sitename <- input_re()[["moduleConfig-config_sitename"]]

      # check if source path is present
      # identical(rv$sourcefiledir, character(0)) returns boolean
      print(rv$sourcefiledir)
      if (identical(rv$sourcefiledir, character(0)) || any(grepl("\\s", rv$sourcefiledir)) || is.null(rv$sourcefiledir)){
        shiny::showModal(modalDialog(
          title = "Invalid values",
          "No empty strings or spaces allowed in the source file path configuration."
        ))
        rv$sql <- NULL
      } else {
        filelist <- list.files(path=rv$sourcefiledir, pattern = "\\.CSV|\\.csv", full.names = T)
        # iterate over list and check for presence of required filenames: FALL.CSV, FAB.CSV, ICD.CSV, OPS.CSV
        check <- sapply(filelist, function(i){
          cat("\n", i, "\n")
          return(grepl("FALL\\.CSV$|FAB\\.CSV$|ICD\\.CSV$|OPS.CSV$", i))
        })

        tryCatch({
          # test if there are exact 4 source files
          if (base::sum(check)!=4){
            shiny::showModal(modalDialog(
              title = "Invalid path",
              "The specified directory does not contain the 4 neccessary CSV-files (FALL.CSV, FAB.CSV, ICD.CSV, OPS.CSV)."
            ))
            rv$sql <- NULL
          }
        }, error = function(e){
          shiny::showModal(modalDialog(
            title = "Invalid path",
            "There are no CSV-files in the specified directory."
          ))
          rv$sql <- NULL
        })
      }
    }


    if (!is.null(rv$sql)){
      rv$target_getdata <- TRUE
      rv$source_getdata <- TRUE

      if (!dir.exists(paste0(tempdir(), "/_settings/"))){
        dir.create(paste0(tempdir(), "/_settings/"))
      }

      # save user settings
      writeLines(jsonlite::toJSON(list("db" = rv$target_db,
                                       "source_path" = rv$sourcefiledir,
                                       "site_name" = rv$sitename),
                                  pretty = T,
                                  auto_unbox = F),
                 paste0(tempdir(), "/_settings/global_settings.JSON"))

    } else {
      cat("\nSQL not loaded yet\n")
    }
  })

  # calculate overview
  # target
  # patient_identifier_value
  observe({
    req(rv$list_target$dt.patient_target)

    if (nrow(rv$dash_summary_target) < 4){
      cat("\nBuild rv$dash_summary_target")
      if (isFALSE("patient.identifier.value" %in% rv$dash_summary_target[,get("variable")])){
        rv[["ov.patient_target.summary"]] <- countUnique(rv$list_target$dt.patient_target, "patient_identifier_value", rv$target_db)
        rv$dash_summary_target <- rbind(rv$dash_summary_target, rv$ov.patient_target.summary[,c("variable", "distinct", "valids", "missings"), with=F])
      }
    }
  })
  # encounter_identifier_value
  observe({
    req(rv$list_target$dt.encounter_target)

    if (nrow(rv$dash_summary_target) < 4){
      cat("\nBuild rv$dash_summary_target2")
      if (isFALSE("encounter.identifier.value" %in% rv$dash_summary_target[,get("variable")])){
        rv[["ov.encounter_target.summary"]] <- countUnique(rv$list_target$dt.encounter_target, "encounter_identifier_value", rv$target_db)
        rv$dash_summary_target <- rbind(rv$dash_summary_target, rv$ov.encounter_target.summary[,c("variable", "distinct", "valids", "missings")])
      }
    }
  })
  # condition_code_coding_code
  observe({
    req(rv$list_target$dt.condition_target)

    if (nrow(rv$dash_summary_target) < 4){
      cat("\nBuild rv$dash_summary_target3")
      if (isFALSE("condition.code.coding.code" %in% rv$dash_summary_target[,get("variable")])){
        rv[["ov.condition_target.summary"]] <- countUnique(rv$list_target$dt.condition_target, "condition_code_coding_code", rv$target_db)
        rv$dash_summary_target <- rbind(rv$dash_summary_target, rv$ov.condition_target.summary[,c("variable", "distinct", "valids", "missings")])
      }
    }
  })
  # procedure_code_coding_code
  observe({
    req(rv$list_target$dt.procedure_target)

    if (nrow(rv$dash_summary_target) < 4){
      cat("\nBuild rv$dash_summary_target4")
      if (isFALSE("procedure.code.coding.code" %in% rv$dash_summary_target[,get("variable")])){
        rv[["ov.procedure_target.summary"]] <- countUnique(rv$list_target$dt.procedure_target, "procedure_code_coding_code", rv$target_db)
        rv$dash_summary_target <- rbind(rv$dash_summary_target, rv$ov.procedure_target.summary[,c("variable", "distinct", "valids", "missings")])
      }
    }
  })

  # source
  observe({
    req(rv$list_source$FALL.CSV)
    if (nrow(rv$dash_summary_source) < 2){
      shiny::withProgress(message = "Creating dashboard summary", value = 0, {
        shiny::incProgress(1/1, detail = "... calculating overview counts ...")

        if (isFALSE("patient_identifier_value" %in% rv$dash_summary_source[,get("variable")])){
          rv[["ov.patient_source.summary"]] <- countUnique(rv$list_source$FALL.CSV, "patient_identifier_value", "csv")
          rv$dash_summary_source <- rbind(rv$dash_summary_source, rv$ov.patient_source.summary[,c("variable", "distinct", "valids", "missings"), with=F])
        }
        if (isFALSE("encounter_identifier_value" %in% rv$dash_summary_source[,get("variable")])){
          rv[["ov.encounter_source.summary"]] <- countUnique(rv$list_source$FALL.CSV, "encounter_identifier_value", "csv")
          rv$dash_summary_source <- rbind(rv$dash_summary_source, rv$ov.encounter_source.summary[,c("variable", "distinct", "valids", "missings"), with=F])
        }
        if (isFALSE("Begleitpersonen" %in% rv$dash_summary_source[,get("variable")])){
          tab <- countUnique(rv$list_source$FALL.CSV[get("encounter_hospitalization_admitSource")=="B",], "encounter_identifier_value", "csv")
          if (nrow(tab) == 0){
            cat("\nThere are no chaperones present in your data.\n")
          }
          rv[["ov.chaperone_source.summary"]] <- tab[1,("variable"):="Begleitpersonen"]
          rv$dash_summary_source <- rbind(rv$dash_summary_source, rv$ov.chaperone_source.summary[,c("variable", "distinct", "valids", "missings"),with=F])
        }
      })
    }
  })

  # observe for load data button
  observe({
    if (!is.null(rv$db_con)){
      shinyjs::hide("dash_instruction")
      return(TRUE)
    }
  })

  # render dashboard summary
  observe({
    if(nrow(rv$dash_summary_target) > 0) {
      output$dash_summary_target <- renderTable({
        tab <- rv$dash_summary_target
        colnames(tab) <- c("Variable", "# Distinct", "# Valid", "# Missing")
        tab
      })
    }

    if(nrow(rv$dash_summary_source) > 0) {
      output$dash_summary_source <- renderTable({
        tab <- rv$dash_summary_source
        colnames(tab) <- c("Variable", "# Distinct", "# Valid", "# Missing")
        tab
      })
    }
  })

  observe({
    req(rv$dqa_descriptive_results)

    # workaround to tell ui, that db_connection is there
    output$etl_results <- reactive({
      return(TRUE)
    })
    outputOptions(output, 'etl_results', suspendWhenHidden=FALSE)

    output$dash_quick_etlchecks <- DT::renderDataTable({
      dat <- quickETLChecks(rv$dqa_descriptive_results)
      renderQuickChecks(dat)
    })
  })

  observe({
    req(rv$conformance$value_conformance)

    # workaround to tell ui, that db_connection is there
    output$valueconformance_results <- reactive({
      return(TRUE)
    })
    outputOptions(output, 'valueconformance_results', suspendWhenHidden=FALSE)

    output$dash_quick_valueconformance_checks <- DT::renderDataTable({
      dat <- quickValueConformanceChecks(rv$conformance$value_conformance)
      renderQuickChecks(dat)
    })
  })

  # observe rv$duration
  observe({
    req(rv$duration)

    output$dash_instruction <- renderText({
      paste0("Started: ", rv$start.time,
             "\nFinished: ", rv$end.time,
             "\nDuration: ", round(rv$duration, 2), " min.")
    })
    shinyjs::show("dash_instruction")
  })



  observeEvent(input_re()[["moduleDashboard-dash_send_datamap"]], {
    # https://stackoverflow.com/questions/27650331/adding-an-email-button-in-shiny-using-tabletools-or-otherwise
    shinyjs::logjs("Send datamap")
    # https://stackoverflow.com/questions/37795760/r-shiny-add-weblink-to-actionbutton
    # sendlink <- paste0("location.href=",
    #                    "\"mailto:imi-miracum-diz-projektanfragen@lists.fau.de?",
    #                    "body=",
    #                    utils::URLencode(paste0("This is an automatically created Email.\n\n\nData Map\n\nSite name: ", rv$sitename,
    #                                            "\n\nR-Package version 'miRacumDQA': ", packageVersion("miRacumDQA"))),
    #                    "&subject='Data Map Report'\"")
    # https://stackoverflow.com/questions/45880437/r-shiny-use-onclick-option-of-actionbutton-on-the-server-side
    # shinyjs::runjs(sendlink)
  })
}


#' @title moduleDashboardUI
#'
#' @param id A character. The identifier of the shiny object
#'
#' @export
#'
# moduleDashboardUI
moduleDashboardUI <- function(id){
  ns <- NS(id)

  tagList(
    fluidRow(
      column(6,
             box(title = "Welcome to your MIRACUM Data-Quality-Analysis Dashboard",
                 verbatimTextOutput(ns("dash_instruction")),
                 conditionalPanel(
                   condition = "output['moduleConfig-dbConnection']",
                   actionButton(ns("dash_load_btn"), "Load data")
                 ),
                 width = 12
             ),
             conditionalPanel(
               condition = "output['moduleDashboard-etl_results']",
               box(title = "Quick ETL Checks: ",
                   DT::dataTableOutput(ns("dash_quick_etlchecks")),
                   width = 12
               )
             ),
             conditionalPanel(
               condition = "output['moduleDashboard-valueconformance_results']",
               box(title = "Quick Value Conformance Checks: ",
                   DT::dataTableOutput(ns("dash_quick_valueconformance_checks")),
                   width = 12
               )
             )
      ),
      column(6,
             conditionalPanel(
               condition = "output['moduleDashboard-etl_results']",
               box(title = "Target System Overview (Data Map)",
                   tableOutput(ns("dash_summary_target")),
                   tags$hr(),
                   tags$a(actionButton(ns("dash_send_datamap"), "Send Data Map", icon = icon("envelope", lib = "font-awesome")),
                          # https://stackoverflow.com/questions/27650331/adding-an-email-button-in-shiny-using-tabletools-or-otherwise
                          # https://stackoverflow.com/questions/37795760/r-shiny-add-weblink-to-actionbutton
                          # https://stackoverflow.com/questions/45880437/r-shiny-use-onclick-option-of-actionbutton-on-the-server-side
                          # https://stackoverflow.com/questions/45376976/use-actionbutton-to-send-email-in-rshiny
                          href = paste0("mailto:imi-miracum-diz-projektanfragen@lists.fau.de?",
                                        "body=",
                                        utils::URLencode(paste0("This is an automatically created Email.\n\n\nData Map\n\nSite name: ", rv$sitename,
                                                                "\n\nR-Package version 'miRacumDQA': ", packageVersion("miRacumDQA"),
                                                                "\n\nLast DQA-Tool run: ", rv$end.time,
                                                                "\nRun duration: ", rv$duration)),
                                        "&subject='Data Map Report'")),
                   width = 12
               ),
               box(title = "Source System Overview",
                   tableOutput(ns("dash_summary_source")),
                   width = 12
               )
             )
      )
    )
  )
}
