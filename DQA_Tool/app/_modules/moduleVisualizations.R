# (c) 2019 Lorenz Kapsner
# moduleVisualizationsServer
moduleVisualizationsServer <- function(input, output, session, rv, input_re){
  
  output$visualizations_plot <- renderPlot({
    hist(rv$list_target$dt.ageindays_target[,encounter_subject_patient_age_days])
  })
}


moduleVisualizationsUI <- function(id){
  ns <- NS(id)
  
  tagList(
    tagList(
      plotOutput(ns("visualizations_plot"))
    )
  )
}
