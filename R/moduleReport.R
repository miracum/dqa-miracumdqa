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

#' @title moduleReportServer
#'
#' @param input Shiny server input object
#' @param output Shiny server output object
#' @param session Shiny session object
#' @param rv The global 'reactiveValues()' object, defined in server.R
#' @param input_re The Shiny server input object, wrapped into a reactive expression: input_re = reactive({input})
#'
#' @export
#'
# moduleReportServer
moduleReportServer <- function(input, output, session, rv, input_re){

  observe({
    # wait here for flag to create report; this can be done, when everything we need for the report is there
    req(rv$create_report)

    # for debugging purposes
    descriptive_results <<- rv$dqa_descriptive_results
    # plausi_out <<- rv$dqa_plausibility_results
    # conformance_out <<- rv$conformance
    # source_data <<- rv$list_source
    # target_data <<- rv$list_target

    # TODO one could remove raw-data here
    rv$list_target <- NULL
    rv$list_source <- NULL
    cat("\nRemoved original files\n")
    gc()

    if (is.null(rv$report_created)){
      shiny::withProgress(
        message = paste0("Creating report ..."), value = 0, {
          shiny::incProgress(1/1, detail = "... working hard to create pdf ...")
          # create pdf from shiny:
          # https://stackoverflow.com/questions/34029611/how-to-use-objects-from-global-environment-in-rstudio-markdown
          knitr::knit(input="./_utilities/RMD/DQA_report.Rmd", output=paste0(tempdir(), "/DQA_report.md"), encoding = "UTF-8")
          # copy header-folder to tempdir to make files available for the next command
          file.copy("./_utilities/RMD/_header", tempdir(), recursive=TRUE)
          rmarkdown::render(input=paste0(tempdir(), "/DQA_report.md"), output_file = paste0(tempdir(), "/DQA_report.pdf"), encoding = "UTF-8")

          # debugging
          # setwd(paste0(getwd(), "/inst/application"))
          # knitr::knit(input="./_utilities/RMD/DQA_report_debug.Rmd", output=paste0(tempdir(), "/DQA_report_debug.md"), encoding = "UTF-8")
          # # copy header-folder to tempdir to make files available for the next command
          # file.copy("./_utilities/RMD/_header", tempdir(), recursive=TRUE)
          # rmarkdown::render(input=paste0(tempdir(), "/DQA_report_debug.md"), output_file = paste0(tempdir(), "/DQA_report_debug.pdf"), encoding = "UTF-8")
        })

      rv$report_created <- TRUE
    }
  })


  output$download_report <- downloadHandler(
    filename = function(){"DQA_report.pdf"},
    content = function(file){
      file.copy(paste0(tempdir(), "/DQA_report.pdf"), file)
    },
    contentType = "application/pdf"
  )
}

#' @title moduleReportUI
#'
#' @param id A character. The identifier of the shiny object
#'
#' @export
#'
# moduleReportUI
moduleReportUI <- function(id){
  ns <- NS(id)

  tagList(
    fluidRow(
      box(title = "Reporting",
          downloadButton(ns("download_report"), "Download Report", style="white-space: normal; text-align:center;
                                                                  padding: 9.5px 9.5px 9.5px 9.5px;
                                                                  margin: 6px 10px 6px 10px;"),
          width = 6
      )
    )
  )
}
