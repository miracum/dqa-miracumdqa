# moduleDashboardServer
moduleDashboardServer <- function(input, output, session, rv, input_re){
  output$dash_instruction <- renderText({
    paste0("Please configure and test your database connection in the settings tab.\nThen return here in order to load the data.")
  })
  
  observeEvent(input_re()[["moduleDashboard-dash_load_btn"]], {
    # check database connection
    testDBcon(rv)
    
    # check if sitename is present
    if (nchar(input_re()[["moduleConfig-config_sitename"]]) < 2 || any(grepl("\\s", input_re()[["moduleConfig-config_sitename"]]))){
      showModal(modalDialog(
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
        showModal(modalDialog(
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
          if (sum(check)!=4){
            showModal(modalDialog(
              title = "Invalid path",
              "The specified directory does not contain the 4 neccessary CSV-files (FALL.CSV, FAB.CSV, ICD.CSV, OPS.CSV)."
            ))  
            rv$sql <- NULL
          } 
        }, error = function(e){
          showModal(modalDialog(
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
      
      if (!dir.exists("./_settings/")){
        dir.create("./_settings/")
      }
      
      # save user settings
      writeLines(toJSON(list("db" = rv$target_db,
                             "source_path" = rv$sourcefiledir,
                             "site_name" = rv$sitename),
                        pretty = T,
                        auto_unbox = F),
                 "./_settings/global_settings.JSON")
      
    } else {
      cat("\nSQL not loaded yet\n")
    }
  })
  
  # calculate overview
  # target
  observe({
    req(rv$list_target$dt.patient_target)
    if (nrow(rv$dash_summary_target) < 2){
      cat("\nBuild rv$dash_summary_target")
      if (!("patient.identifier.value" %in% rv$dash_summary_target[,variable])){
        rv[["ov.patient_target.summary"]] <- countUnique(rv$list_target$dt.patient_target, "patient_identifier_value", rv$target_db)
        rv$dash_summary_target <- rbind(rv$dash_summary_target, rv$ov.patient_target.summary[,.(variable, distinct, valids, missings)])
      }
    }
  })
  observe({
    req(rv$list_target$dt.encounter_target)
    if (nrow(rv$dash_summary_target) < 2){
      cat("\nBuild rv$dash_summary_target2")
      if (!("encounter.identifier.value" %in% rv$dash_summary_target[,variable])){
        rv[["ov.encounter_target.summary"]] <- countUnique(rv$list_target$dt.encounter_target, "encounter_identifier_value", rv$target_db)
        rv$dash_summary_target <- rbind(rv$dash_summary_target, rv$ov.encounter_target.summary[,.(variable, distinct, valids, missings)])
      }
    }
  })
  
  # source
  observe({
    req(rv$list_source$FALL.CSV)
    if (nrow(rv$dash_summary_source) < 2){
      cat("\nBuild rv$dash_summary_source")
      if (!("PATIENTENNUMMER" %in% rv$dash_summary_source[,variable])){
        rv[["ov.patient_source.summary"]] <- countUnique(rv$list_source$FALL.CSV, "PATIENTENNUMMER", "csv")
        rv$dash_summary_source <- rbind(rv$dash_summary_source, rv$ov.patient_source.summary[,.(variable, distinct, valids, missings)])
      }
      if (!("KH_INTERNES_KENNZEICHEN" %in% rv$dash_summary_source[,variable])){
        rv[["ov.encounter_source.summary"]] <- countUnique(rv$list_source$FALL.CSV, "KH_INTERNES_KENNZEICHEN", "csv")
        rv$dash_summary_source <- rbind(rv$dash_summary_source, rv$ov.encounter_source.summary[,.(variable, distinct, valids, missings)])
      }
      if (!("Begleitpersonen" %in% rv$dash_summary_source[,variable])){
        tab <- countUnique(rv$list_source$FALL.CSV[AUFNAHMEANLASS=="B",], "KH_INTERNES_KENNZEICHEN", "csv")
        if (nrow(tab) == 0){
          cat("\nThere are no chaperones present in your data.\n")
        } 
        rv[["ov.chaperone_source.summary"]] <- tab[1,variable:="Begleitpersonen"]
        rv$dash_summary_source <- rbind(rv$dash_summary_source, rv$ov.chaperone_source.summary[,.(variable, distinct, valids, missings)])
      }
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
}



# moduleDashboardUI
moduleDashboardUI <- function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(6,
             box(title = "Welcome to your MIRACUM Data-Quality-Analysis dashboard",
                 verbatimTextOutput(ns("dash_instruction")),
                 conditionalPanel(
                   condition = "output['moduleConfig-dbConnection']",
                   actionButton(ns("dash_load_btn"), "Load data")
                 ),
                 width = 12
             )
      ),
      column(6,
             conditionalPanel(
               condition = "output['moduleConfig-dbConnection']",
               box(title = "Target system overview",
                   tableOutput(ns("dash_summary_target")),
                   width = 12
               )
             ),
             conditionalPanel(
               condition = "output['moduleConfig-dbConnection']",
               box(title = "Source system overview",
                   tableOutput(ns("dash_summary_source")),
                   width = 12
               )
             )
      ) 
    )
  )
}