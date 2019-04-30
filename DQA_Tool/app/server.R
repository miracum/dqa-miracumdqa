shinyServer(function(input, output, session) {

    # if you want to source any files with functions, do it inside the server-function, so the information will not be shared across sessions
    source("./_utilities/functions.R", encoding = "UTF-8")
    
    # define reactive values here
    rv <- reactiveValues(
        file = NULL,
        db_settings = NULL,
        db_con = NULL,
        db_getdata = FALSE,
        data_objects = list()
    )
    
    
    
    ########################
    # tab_config
    ########################
    # observe source file directory
    observe({
        shinyDirChoose(input, "config_sourcedir_in", updateFreq = 0, session = session, defaultPath = "", roots = c(home="/home/"), defaultRoot = "home")
        
        output$config_sourcedir_out <- reactive({
            roots = c(home="/home/")
            sourcefiledir <- parseDirPath(roots, input$config_sourcedir_in)
            paste(sourcefiledir)
        })
    })
    
    # observe target database configuration
    observeEvent(input$config_targetdb_rad, {
        print(input$config_targetdb_rad)
        
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
                rv$sql <- fromJSON("./_utilities/SQL_i2b2.JSON")
            } else if (input$config_targetdb_rad == "omop"){
                rv$sql <- fromJSON("./_utilities/SQL_omop.JSON")
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
        testDBcon(rv)
        
        if (!is.null(rv$sql)){
            rv$db_getdata <- TRUE
            
            output$menu <- renderMenu({
                sidebarMenu(
                    menuItem("Raw data", tabName = "tab_rawdata1", icon = icon("table"))
                )
            })
            updateTabItems(session, "tabs", "tab_rawdata1")
            
            output$rawdata1_uiout <- renderUI({
                selectInput("rawdata1_sel", "Data object", rv$data_objects, multiple=TRUE, selectize=FALSE)
            })
            
            shinyjs::disable("dash_load_btn")
            
        } else {
            cat("\nSQL not loaded yet\n")
        }
    })
    
    # TODO overview: count encounter ids, count begleitlieger, count patient ids
    
    ########################
    # tab_rawdata1
    ########################
    # dt_patient.db
    observe({
        req(rv$db_getdata)
        vec <- c("dt_patient.db", "dt_visit.db", "dt_aitaa.db", "dt_aijaa.db",
                 "dt_aufnan.db", "dt_aufngr.db", "dt_entlgr.db", "dt_beatmst.db",
                 "dt_icd.db", "dt_ops.db", "dt_fab.db",
                 "dt_pl_c5x.db", "dt_pl_c6x.db", "dt_pl_05xx.db", "dt_pl_o0099.db")
        
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
