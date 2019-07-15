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

# moduleRawdata1Server
moduleRawdata1Server <- function(input, output, session, rv, input_re){
  
  observe({
    if (length(rv$data_objects) > 0){
      # render select input here
      output$rawdata1_uiout <- renderUI({
        selectInput(session$ns("rawdata1_sel"), "Select data object", rv$data_objects, multiple=FALSE, selectize=FALSE, size = 15)
      })
    }
  })
  
  observe({
    req(rv$target_getdata)
    if (isTRUE(rv$target_getdata)){
      # get data from database
      
      rv$list_target <- sapply(rv$target_keys, function(i){
        shinyjs::logjs(paste("Getting", i, "from database."))
        fireSQL(rv, i)
      }, simplify = F, USE.NAMES = T)
      rv$target_getdata <- FALSE
      RPostgres::dbDisconnect(rv$db_con)
    }
    
    
    if (isFALSE(rv$target_getdata)){
      # transform to categorical
      shiny::withProgress(message = "Transforming target variable types", value = 0, {
        for (i in rv$target_keys){
          shiny::incProgress(1/length(rv$target_keys), detail = paste("... transforming", i, "..."))
          
          # get column names
          col_names <- colnames(rv$list_target[[i]])
          
          # check, if column name in variables of interest
          for (j in col_names){
            
            if (j %in% rv$trans_vars){
              rv$list_target[[i]][,(j):=transformFactor(data.table::get(j), j)]
            }
            
            # transform cat_vars to factor
            if (j %in% rv$cat_vars){
              rv$list_target[[i]][,(j):=factor(data.table::get(j))]
            }
          }
        }
      })
    }
  })
  
  observe({
    req(rv$source_getdata)
    if (isTRUE(rv$source_getdata)){
      # get data from csv files
      cat("\nReading from csv\n")
      
      rv$list_source <- sapply(rv$source_keys, function(i){
        loadCSV(rv, i)
      }, simplify = F, USE.NAMES = T)
      
      rv$source_getdata <- FALSE
    }
    
    if (isFALSE(rv$source_getdata)){
      
      # transform to date
      shiny::withProgress(message = "Transforming source variable types", value = 0, {
        # rename colnames of source data to fhir (variable_names) and transform to dates
        for (i in rv$source_keys){
          shiny::incProgress(1/length(rv$source_keys), detail = paste("... transforming", i, "..."))
          
          # get column names
          col_names <- colnames(rv$list_source[[i]])
          
          # check, if column name in variables of interest
          # var_names of interest:
          var_names <- rv$mdr[source_table_name==i,][grepl("dt\\.", key),source_variable_name]
          
          for (j in col_names){
            if (j %in% var_names){
              vn <- rv$mdr[source_table_name==i,][grepl("dt\\.", key),][source_variable_name==j,variable_name]
              colnames(rv$list_source[[i]])[which(col_names==j)] <- vn
              
              # transform date_vars to dates
              if (vn %in% rv$date_vars){
                rv$list_source[[i]][,(vn):=as.Date(substr(as.character(data.table::get(vn)), 1, 8), format="%Y%m%d")]
              }
              
              if (vn %in% rv$trans_vars){
                rv$list_source[[i]][,(vn):=transformFactor(data.table::get(vn), vn)]
              }
              
              # transform cat_vars to factor
              if (vn %in% rv$cat_vars){
                rv$list_source[[i]][,(vn):=factor(data.table::get(vn))]
              }
            }
          }
        }
      })
      
      # read source plausibilities after data transformation
      shiny::withProgress(message = "Getting plausibilities", value = 0, {
        for (i in unique(names(rv$pl_vars))){
          if (grepl("_source", rv$pl_vars[[i]])){
            j <- rv$pl_vars[[i]]
            shiny::incProgress(1/length(rv$source_keys), detail = paste("... getting", j, "..."))
            rv$list_source[[j]] <- loadSourcePlausibilities(j, rv)
          }
        }
      })
      
    }
  })
  
  
  observeEvent(input_re()[["moduleRawdata1-rawdata1_sel"]], {
    if (grepl("target", input_re()[["moduleRawdata1-rawdata1_sel"]])){
      selection <- rv$list_target[[input_re()[["moduleRawdata1-rawdata1_sel"]]]]
    } else {
      selection <- rv$list_source[[input_re()[["moduleRawdata1-rawdata1_sel"]]]]
    }
    output$rawdata1_table <- DT::renderDataTable({
      DT::datatable(selection, options = list(scrollX = TRUE, pageLength = 20, dom="ltip"))
    })
  })
}

moduleRawdata1UI <- function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(title = "Select data",
          uiOutput(ns("rawdata1_uiout")),
          width = 4
      ),
      box(
        title = "Review raw data",
        dataTableOutput(ns("rawdata1_table")),
        width = 8
      )
    )
  )
}