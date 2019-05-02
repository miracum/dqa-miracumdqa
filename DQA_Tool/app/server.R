shinyServer(function(input, output, session) {
    
    # if you want to source any files with functions, do it inside the server-function, so the information will not be shared across sessions
    source("./_utilities/functions.R", encoding = "UTF-8")
    source("./_utilities/statistics.R", encoding = "UTF-8")
    
    # define reactive values here
    rv <- reactiveValues(
        mdr = NULL,
        file = NULL,
        sourcefiledir = NULL,
        sitename = NULL,
        db_settings = NULL,
        db_con = NULL,
        target_getdata = NULL,
        source_getdata = NULL,
        data_objects = list(),
        dash_summary_target = summaryTable(),
        dash_summary_source = summaryTable(),
        csv_keys = c("FALL.CSV", "FAB.CSV", "ICD.CSV", "OPS.CSV")
    )
    
    
    # run onStart here
    onStart(session, rv, input, output)
    
    # read mdr
    observe({
        if (is.null(rv$mdr)){
            cat("\nRead MDR\n")
            rv$mdr <- fread("./_utilities/DQ_MDR.csv", header = T)
        }
    })
    
    
    # handle reset
    observeEvent(input$reset, {
        js$reset()
    })
    
    
    
    ########################
    # tab_config
    ########################
    # observe source file directory
    observeEvent(input$config_sourcedir_in, {
        shinyDirChoose(input, "config_sourcedir_in", updateFreq = 0, session = session, defaultPath = "", roots = c(home="/home/"), defaultRoot = "home")
        #if (identical(rv$sourcefiledir, character(0)) || is.null(rv$sourcefiledir)){
        roots = c(home="/home/")
        rv$sourcefiledir <- parseDirPath(roots, input$config_sourcedir_in)
        #}
    })
    
    output$config_sourcedir_out <- reactive({
        cat("\nSource file dir:", rv$sourcefiledir, "\n")
        paste(rv$sourcefiledir)
    })
    
    # observe target database configuration
    observeEvent(input$config_targetdb_rad, {
        print(input$config_targetdb_rad)
        
        # remove existing global_settings here as they will newly be created once loading the data
        if (file.exists("_settings/global_settings.JSON")){
            if (input$config_targetdb_rad != rv$user_settings[["db"]]){
                cat("\nRemoving '_settings/global_settings.JSON'")
                file.remove("_settings/global_settings.JSON")
                rv$user_settings <- NULL
            }
        }
        
        # if "./_utilities/settings.yml" not present, read default settings list here and populate textInputs
        if (!file.exists(paste0("./_settings/settings_", input$config_targetdb_rad, ".JSON"))){
            cat("\nReading default settings\n")
            rv$db_settings <- config::get(input$config_targetdb_rad, file = "./_utilities/settings_default.yml")
            
            showModal(modalDialog(
                "Loading default configuration.", 
                title = "Loading default database configuration")
            )
        } else {
            rv$db_settings <- fromJSON(paste0("./_settings/settings_", input$config_targetdb_rad, ".JSON"))
        }
        
        updateTextInput(session, "config_targetdb_dbname", value = rv$db_settings$dbname)
        updateTextInput(session, "config_targetdb_hostname", value = rv$db_settings$host)
        updateTextInput(session, "config_targetdb_port", value = rv$db_settings$port)
        updateTextInput(session, "config_targetdb_user", value = rv$db_settings$user)
        updateTextInput(session, "config_targetdb_password", value = rv$db_settings$password)
    })
    
    # observe saving of settings
    observeEvent(input$config_targetdb_save_btn,{
        rv$db_settings <- getDBsettings(input, rv)
        
        if (!is.null(rv$db_settings)){
            print(rv$db_settings)
            
            if (!dir.exists("./_settings/")){
                dir.create("./_settings/")
            }
            
            writeLines(toJSON(rv$db_settings,
                              pretty = T,
                              auto_unbox = F),
                       paste0("./_settings/settings_", input$config_targetdb_rad, ".JSON"))
        }
    })
    
    # test db-connection
    observeEvent(input$config_targetdb_test_btn, {
        rv$db_settings <- getDBsettings(input, rv)
        
        if (!is.null(rv$db_settings)){
            
            testDBcon(rv)
            
            if (!is.null(rv$db_con)){
                cat("\nDB connection successfully established\n")
                showModal(modalDialog(
                    title = "Database connection successfully tested",
                    "The database connection has been successfully established and tested."
                ))
            }
            
            # workaround to tell ui, that db_connection is there
            output$dbConnection <- reactive({
                if (!is.null(rv$db_con)){
                    shinyjs::hide("dash_instruction")
                    return(TRUE)
                } else {
                    shinyjs::show("dash_instruction")
                    return(FALSE)
                }
            })
            outputOptions(output, 'dbConnection', suspendWhenHidden=FALSE)
        }
    })
    
    # load sql statements
    observe({
        req(rv$db_con)
        
        if (is.null(rv$sql)){
            if (input$config_targetdb_rad == "i2b2"){
                cat("\nLoading i2b2 SQLs\n")
                rv$sql <- fromJSON("./_utilities/SQL/SQL_i2b2.JSON")
            } else if (input$config_targetdb_rad == "omop"){
                cat("\nLoading omop SQLs\n")
                rv$sql <- fromJSON("./_utilities/SQL/SQL_omop.JSON")
            }
        }
    })
    
    
    ########################
    # tab_dashboard
    ########################
    output$dash_instruction <- renderText({
        paste0("Please configure and test your database connection in the settings tab.\nThen return here in order to load the data.")
    })
    
    observeEvent(input$dash_load_btn, {
        # check database connection
        testDBcon(rv)
        
        # check if sitename is present
        if (nchar(input$config_sitename) < 2 || any(grepl("\\s", input$config_sitename))){
            showModal(modalDialog(
                title = "Invalid values",
                "No empty strings or spaces allowed in the site name configuration."
            ))
            rv$sql <- NULL
        } else {
            rv$sitename <- input$config_sitename
            
            # check if source path is present
            # identical(rv$sourcefiledir, character(0)) returns boolean
            if (identical(rv$sourcefiledir, character(0)) || any(grepl("\\s", rv$sourcefiledir))){
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
            
            # disable config page
            shinyjs::disable("config_targetdb_rad")
            shinyjs::disable("config_targetdb_dbname")
            shinyjs::disable("config_targetdb_hostname")
            shinyjs::disable("config_targetdb_port")
            shinyjs::disable("config_targetdb_user")
            shinyjs::disable("config_targetdb_password")
            shinyjs::disable("config_targetdb_save_btn")
            shinyjs::disable("config_targetdb_test_btn")
            shinyjs::disable("config_sitename")
            shinyjs::disable("config_sourcedir_in")
            
            # save user settings
            writeLines(toJSON(list("db" = input$config_targetdb_rad,
                                   "source_path" = rv$sourcefiledir,
                                   "site_name" = rv$sitename),
                              pretty = T,
                              auto_unbox = F),
                       "./_settings/global_settings.JSON")
            
            # render menu
            output$menu <- renderMenu({
                sidebarMenu(
                    menuItem("Review raw data", tabName = "tab_rawdata1", icon = icon("table"))
                )
            })
            updateTabItems(session, "tabs", "tab_rawdata1")
            
            # render select input here
            output$rawdata1_uiout <- renderUI({
                selectInput("rawdata1_sel", "Data object", rv$data_objects, multiple=FALSE, selectize=FALSE, size = 15)
            })
            
            # hide load data button
            shinyjs::hide("dash_load_btn")
            
        } else {
            cat("\nSQL not loaded yet\n")
        }
    })
    
    # calculate overview
    # target
    observe({
        req(rv$dt.patient_target)
        if (nrow(rv$dash_summary_target) < 2){
            cat("\nBuild rv$dash_summary_target")
            if (!("patient.identifier.value" %in% rv$dash_summary_target[,variable])){
                rv[["ov.patient_target.summary"]] <- countUnique(rv$dt.patient_target, "patient_identifier_value", input$config_targetdb_rad)
                rv$dash_summary_target <- rbind(rv$dash_summary_target, rv$ov.patient_target.summary[,.(variable, distinct, valids, missings)])
            }
        }
    })
    observe({
        req(rv$dt.encounter_target)
        if (nrow(rv$dash_summary_target) < 2){
            cat("\nBuild rv$dash_summary_target2")
            if (!("encounter.identifier.value" %in% rv$dash_summary_target[,variable])){
                rv[["ov.encounter_target.summary"]] <- countUnique(rv$dt.encounter_target, "encounter_identifier_value", input$config_targetdb_rad)
                rv$dash_summary_target <- rbind(rv$dash_summary_target, rv$ov.encounter_target.summary[,.(variable, distinct, valids, missings)])
            }
        }
    })
    
    # source
    observe({
        req(rv$FALL.CSV)
        if (nrow(rv$dash_summary_source) < 2){
            cat("\nBuild rv$dash_summary_source")
            if (!("PATIENTENNUMMER" %in% rv$dash_summary_source[,variable])){
                rv[["ov.patient_source.summary"]] <- countUnique(rv$FALL.CSV, "PATIENTENNUMMER", "csv")
                rv$dash_summary_source <- rbind(rv$dash_summary_source, rv$ov.patient_source.summary[,.(variable, distinct, valids, missings)])
            }
            if (!("KH_INTERNES_KENNZEICHEN" %in% rv$dash_summary_source[,variable])){
                rv[["ov.encounter_source.summary"]] <- countUnique(rv$FALL.CSV, "KH_INTERNES_KENNZEICHEN", "csv")
                rv$dash_summary_source <- rbind(rv$dash_summary_source, rv$ov.encounter_source.summary[,.(variable, distinct, valids, missings)])
            }
            if (!("Begleitpersonen" %in% rv$dash_summary_source[,variable])){
                tab <- countUnique(rv$FALL.CSV[AUFNAHMEANLASS=="B",], "KH_INTERNES_KENNZEICHEN", "csv")
                if (nrow(tab) == 0){
                    cat("\nThere are no chaperones present in your data.\n")
                } 
                rv[["ov.chaperone_source.summary"]] <- tab[1,variable:="Begleitpersonen"]
                rv$dash_summary_source <- rbind(rv$dash_summary_source, rv$ov.chaperone_source.summary[,.(variable, distinct, valids, missings)])
            }
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
    
    ########################
    # tab_rawdata1
    ########################
    observe({
        req(rv$target_getdata)
        # get data from database
        
        # get keys from our mdr
        rv$db_keys <- rv$mdr[source_system==input$config_targetdb_rad,unique(key)][1:3]
        
        for (i in rv$db_keys){
            if (is.null(eval(parse(text=paste0("rv$", i))))){
                rv[[i]] <- fireSQL(rv, i)
            }
        }
        invisible(gc())
        rv$target_getdata <- FALSE
    })
    
    observe({
        req(rv$source_getdata)
        # get data from csv files
        cat("\nReading from csv\n")
        
        for (i in rv$csv_keys){
            if (is.null(eval(parse(text=paste0("rv$", i))))){
                rv[[i]] <- loadCSV(rv, i)
            }
        }
        
        invisible(gc())
        rv$source_getdata <- FALSE
    })
    
    observeEvent(input$rawdata1_sel, {
        output$rawdata1_table <- DT::renderDataTable({
            DT::datatable(eval(parse(text= input$rawdata1_sel)), options = list(scrollX = TRUE, pageLength = 20))
        })
    })
    
    ########################
    # tab_mdr
    ########################
    output$mdr_table <- DT::renderDataTable({
        DT::datatable(rv$mdr, options = list(scrollX = TRUE, pageLength = 20))
    })
})
