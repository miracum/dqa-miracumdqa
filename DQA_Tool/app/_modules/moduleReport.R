# by Lorenz Kapsner
# moduleReportServer
moduleReportServer <- function(input, output, session, rv, input_re){
  
  
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
          actionButton(ns("create_report"), "Create PDF Report", style="white-space: normal; text-align:center; 
                                                                  padding: 9.5px 9.5px 9.5px 9.5px;
                                                                  margin: 6px 10px 6px 10px;"),
          conditionalPanel(
            condition = "output['reportCreated']",
            downloadButton(ns("download_report"), "Download Report", style="white-space: normal; text-align:center; 
                                                                  padding: 9.5px 9.5px 9.5px 9.5px;
                                                                  margin: 6px 10px 6px 10px;")
          ),
          width = 6
      )
    )
  )
}