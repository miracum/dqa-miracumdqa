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

# moduleConfigServer
moduleConfigServer <- function(input, output, session, rv, input_re){
  roots = c(home="/home/")
  shinyDirChoose(input, "config_sourcedir_in", updateFreq = 0, session = session, defaultPath = "", roots = roots, defaultRoot = "home")
  
  # observe source file directory
  observeEvent(input_re()[["moduleConfig-config_sourcedir_in"]], {
    rv$sourcefiledir <- parseDirPath(roots, input_re()[["moduleConfig-config_sourcedir_in"]])
  })
  
  output$config_sourcedir_out <- reactive({
    cat("\nSource file dir:", rv$sourcefiledir, "\n")
    paste(rv$sourcefiledir)
  })
  
  # observe target database configuration
  observeEvent(input_re()[["moduleConfig-config_targetdb_rad"]], {
    print(input_re()[["moduleConfig-config_targetdb_rad"]])
    rv$target_db <- input_re()[["moduleConfig-config_targetdb_rad"]]
    
    # remove existing global_settings here as they will newly be created once loading the data
    if (file.exists("_settings/global_settings.JSON")){
      if (input_re()[["moduleConfig-config_targetdb_rad"]] != rv$user_settings[["db"]]){
        cat("\nRemoving '_settings/global_settings.JSON'")
        file.remove("_settings/global_settings.JSON")
        rv$user_settings <- NULL
      }
    }
    
    # if "./_utilities/settings.yml" not present, read default settings list here and populate textInputs
    if (!file.exists(paste0("./_settings/settings_", input_re()[["moduleConfig-config_targetdb_rad"]], ".JSON"))){
      cat("\nReading default settings\n")
      rv$db_settings <- config::get(input_re()[["moduleConfig-config_targetdb_rad"]], file = "./_utilities/settings_default.yml")
      
      showModal(modalDialog(
        "Loading default configuration.", 
        title = "Loading default database configuration")
      )
    } else {
      rv$db_settings <- fromJSON(paste0("./_settings/settings_", input_re()[["moduleConfig-config_targetdb_rad"]], ".JSON"))
    }
    
    updateTextInput(session, "config_targetdb_dbname", value = rv$db_settings$dbname)
    updateTextInput(session, "config_targetdb_host", value = rv$db_settings$host)
    updateTextInput(session, "config_targetdb_port", value = rv$db_settings$port)
    updateTextInput(session, "config_targetdb_user", value = rv$db_settings$user)
    updateTextInput(session, "config_targetdb_password", value = rv$db_settings$password)
  })
  
  # observe saving of settings
  observeEvent(input_re()[["moduleConfig-config_targetdb_save_btn"]],{
    rv$db_settings <- getDBsettings(input_re())
    
    if (!is.null(rv$db_settings)){
      print(rv$db_settings)
      
      if (!dir.exists("./_settings/")){
        dir.create("./_settings/")
      }
      
      writeLines(toJSON(rv$db_settings,
                        pretty = T,
                        auto_unbox = F),
                 paste0("./_settings/settings_", input_re()[["moduleConfig-config_targetdb_rad"]], ".JSON"))
    }
  })
  
  # test db-connection
  observeEvent(input_re()[["moduleConfig-config_targetdb_test_btn"]], {
    rv$db_settings <- getDBsettings(input_re())
    
    if (!is.null(rv$db_settings)){
      
      rv$db_con <- testDBcon(rv$db_settings)
      
      if (!is.null(rv$db_con)){
        cat("\nDB connection successfully established\n")
        showModal(modalDialog(
          title = "Database connection successfully tested",
          "The database connection has been successfully established and tested."
        ))
      }
    }
  })
  
  # load sql statements
  observe({
    req(rv$db_con)
    
    if (is.null(rv$sql)){
      if (input_re()[["moduleConfig-config_targetdb_rad"]] == "i2b2"){
        cat("\nLoading i2b2 SQLs\n")
        rv$sql <- fromJSON("./_utilities/SQL/SQL_i2b2.JSON")
      } else if (input_re()[["moduleConfig-config_targetdb_rad"]] == "omop"){
        cat("\nLoading omop SQLs\n")
        rv$sql <- fromJSON("./_utilities/SQL/SQL_omop.JSON")
      }
    }
  })
  
  # workaround to tell ui, that db_connection is there
  output$dbConnection <- reactive({
    if (!is.null(rv$db_con)){
      return(TRUE)
    }
  })
  outputOptions(output, 'dbConnection', suspendWhenHidden=FALSE)
  
  
  observe({
    if (is.null(rv$sitenames)){
      rv$sitenames <- fromJSON("./_utilities/MISC/sitenames.JSON")
      
      updateSelectInput(session, "config_sitename", choices = rv$sitenames, 
                        selected = ifelse(!is.null(rv$sitename), rv$sitename, character(0)))
    }
  })
}

# moduleConfigUI
moduleConfigUI <- function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(6,
             box(
               title = "Target Database Configuration",
                radioButtons(inputId = ns("config_targetdb_rad"), 
                             label = "Please select the target database",
                             choices = list("i2b2" = "i2b2", 
                                            "OMOP" = "omop"), 
                             selected = NULL, 
                             inline = TRUE),
                textInput(ns("config_targetdb_dbname"), label = "Database name"),
                textInput(ns("config_targetdb_host"), label = "Host name"),
                textInput(ns("config_targetdb_port"), label = "Port"),
                textInput(ns("config_targetdb_user"), label = "Username"),
                passwordInput(ns("config_targetdb_password"), label = "Password"),
                div(class = "row", style = "text-align: center;",
                    actionButton(ns("config_targetdb_save_btn"), "Save settings"),
                    actionButton(ns("config_targetdb_test_btn"), "Test connection")),
               width = 12
             )),
      column(6,
             
             box(title = "Sitename",
                 div(class = "row",
                     div(class = "col-sm-8", selectInput(ns("config_sitename"), "Please enter the name of your site",
                                                         selected = F, choices = NULL, multiple = F)),
                     div(class = "col-sm-4")
                 ),
                 width = 12
             ),
             box(title = "Source File Directory",
                 h5(tags$b("Please choose the directory of your §21 source data in csv format")),
                 div(class = "row",
                     div(class="col-sm-3", shinyDirButton(ns("config_sourcedir_in"), 
                                                          "Source Dir", 
                                                          "Please select the source file directory", 
                                                          buttonType = "default", 
                                                          class = NULL, 
                                                          icon = NULL, 
                                                          style = NULL)),
                     div(class = "col-sm-9", verbatimTextOutput(ns("config_sourcedir_out")))
                 ),
                 width = 12
             )
      )
    )
  )
}