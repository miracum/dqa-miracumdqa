# moduleMDRServer
moduleMDRServer <- function(input, output, session, rv, input_re){
  
  output$mdr_table <- DT::renderDataTable({
    DT::datatable(rv$mdr, options = list(scrollX = TRUE, pageLength = 20))
  })
}


moduleMDRUI <- function(id){
  ns <- NS(id)
  
  tagList(
    box(
      title = "DQ Metadatarepository",
      dataTableOutput(ns("mdr_table")),
      width = 12
    )
  )
}
