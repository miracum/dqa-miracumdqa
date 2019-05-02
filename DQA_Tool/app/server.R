shinyServer(function(input, output, session) {

    # if you want to source any files with functions, do it inside the server-function, so the information will not be shared across sessions
    source("./_utilities/functions.R", encoding = "UTF-8")
    source("./_utilities/statistics.R", encoding = "UTF-8")
    
    # define reactive values here
    rv <- reactiveValues(
        file = NULL,
        sourcefiledir = NULL,
        sitename = NULL,
        db_settings = NULL,
        db_con = NULL,
        db_getdata = NULL,
        data_objects = list(),
        dash_summary_target = data.table("variable" = character(), 
                                  "distinct" = integer(), 
                                  "valids" = integer(),
                                  "missings" = integer())
    )
    
    # run onStart here
    onStart(session, rv, output)
    
    # handle reset
    observeEvent(input$reset, {
        js$reset()
    })

    
    ########################
    # tab_config
    ########################
    # observe source file directory
    observe({
        if (identical(rv$sourcefiledir, character(0)) || is.null(rv$sourcefiledir)){
            shinyDirChoose(input, "config_sourcedir_in", updateFreq = 0, session = session, defaultPath = "", roots = c(home="/home/"), defaultRoot = "home")
            roots = c(home="/home/")
            rv$sourcefiledir <- parseDirPath(roots, input$config_sourcedir_in)
        }
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
            cat("\nRemoving '_settings/global_settings.JSON'")
            file.remove("_settings/global_settings.JSON")
        }
        
        # if "./_utilities/settings.yml" not present, read default settings list here and populate textInputs
        if (!file.exists(paste0("./_settings/settings_", input$config_targetdb_rad, ".JSON"))){
            cat("\nReading default settings\n")
            rv$db_settings <- config::get(input$config_targetdb_rad, file = "./_utilities/settings_default.yml")
            
            showModal(modalDialog(
                "Loading default configuration", 
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
                "No empty strings or spaces allowed in the site name configuration"
            ))
            rv$sql <- NULL
        } else {
            rv$sitename <- input$config_sitename
            
            # check if source path is present
            # identical(rv$sourcefiledir, character(0)) returns boolean
            if (identical(rv$sourcefiledir, character(0)) || any(grepl("\\s", rv$sourcefiledir))){
                showModal(modalDialog(
                    title = "Invalid values",
                    "No empty strings or spaces allowed in the source file path configuration"
                ))
                rv$sql <- NULL
            } else {
                # TODO check for required files here: FALL.CSV, FAB.CSV, ICD.CSV, OPS.CSV
                cat("\nPrint list of files in sourcefiledir:\n")
                filelist <- list.files(path=rv$sourcefiledir, pattern = "\\.CSV|\\.csv", full.names = T)
                print(filelist)
            }
        }
        
        
        if (!is.null(rv$sql)){
            rv$db_getdata <- TRUE
            
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
    
    # calculate number of distinct patient ids
    observe({
        req(rv$dt_patient.db)
        if (!("patient_id" %in% rv$dash_summary_target[,variable])){
            rv[["dt_patient.db_summary"]] <- countUnique(rv$dt_patient.db, "patient_id", input$config_targetdb_rad)
            rv$dash_summary_target <- rbind(rv$dash_summary_target, rv$dt_patient.db_summary[,.(variable, distinct, valids, missings)])
        }
    })
    observe({
        req(rv$dt_visit.db)
        if (!("encounter_id" %in% rv$dash_summary_target[,variable])){
            rv[["dt_visit.db_summary"]] <- countUnique(rv$dt_visit.db, "encounter_id", input$config_targetdb_rad)
            rv$dash_summary_target <- rbind(rv$dash_summary_target, rv$dt_visit.db_summary[,.(variable, distinct, valids, missings)])
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
    })
    
    ########################
    # tab_rawdata1
    ########################
    observe({
        req(rv$db_getdata)
        vec <- c("dt_patient.db", "dt_visit.db", "dt_aufnan.db") #, 
                 #"dt_aitaa.db", "dt_aijaa.db", "dt_aufngr.db", "dt_entlgr.db", "dt_beatmst.db") #,
                 # "dt_icd.db", "dt_ops.db", "dt_fab.db",
                 # "dt_pl_c5x.db", "dt_pl_c6x.db", "dt_pl_05xx.db", "dt_pl_o0099.db")
        
        for (i in vec){
            if (is.null(eval(parse(text=paste0("rv$", i))))){
                rv[[i]] <- fireSQL(rv, i)
            }
        }
        invisible(gc())
        rv$db_getdata <- FALSE
    })
    
    observeEvent(input$rawdata1_sel, {
        output$rawdata1_table <- DT::renderDataTable({
            DT::datatable(eval(parse(text= input$rawdata1_sel)), options = list(scrollX = TRUE, pageLength = 20))
        })
    })
})
