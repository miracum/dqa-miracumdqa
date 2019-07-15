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

# moduleVisualizationsServer
moduleVisualizationsServer <- function(input, output, session, rv, input_re){
  
  output$visualizations_plot <- renderPlot({
    graphics::hist(rv$list_target$dt.ageindays_target[,encounter_subject_patient_age_days])
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
