# by Lorenz Kapsner
# moduleReportServer
moduleReportServer <- function(input, output, session, rv, input_re){
  
  observe({
      req(rv$dqa_numerical_results)
      
      withProgress(
        message = paste0("Creating report ..."), value = 0, {
          incProgress(1/1, detail = "... working hard to create pdf ...")
          # create pdf from shiny:
          # https://stackoverflow.com/questions/34029611/how-to-use-objects-from-global-environment-in-rstudio-markdown
          knitr::knit(input="./_utilities/RMD/DQA_report.Rmd", output=paste0(tempdir(), "/DQA_report.md"), encoding = "UTF-8")
          # copy header-folder to tempdir to make files available for the next command
          file.copy("./_utilities/RMD/_header", tempdir(), recursive=TRUE)
          rmarkdown::render(input=paste0(tempdir(), "/DQA_report.md"), output_file = paste0(tempdir(), "/DQA_report.pdf"), encoding = "UTF-8")
        })
  })
  
  
  output$download_report <- downloadHandler(
    filename = function(){"DQA_report.pdf"},
    content = function(file){
      file.copy(paste0(tempdir(), "/DQA_report.pdf"), file)
    },
    contentType = "application/pdf"
  )
}

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