# moduleVisualizationsServer
moduleVisualizationsServer <- function(input, output, session, rv, input_re){
  
  output$visualizations_plot <- renderPlot({
    hist(rv$list_target$dt.ageindays_target[,patient_age_days])
  })
}


moduleVisualizationsUI <- function(id){
  ns <- NS(id)
  
  tagList(
    plotOutput(ns("visualizations_plot"))
  )
}

