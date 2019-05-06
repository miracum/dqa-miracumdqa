shinyServer(function(input, output, session) {
    
    # define reactive values here
    rv <- reactiveValues(
        mdr = NULL,
        file = NULL,
        sourcefiledir = NULL,
        sitename = NULL,
        user_settings = NULL,
        db_settings = NULL,
        db_con = NULL,
        target_db = NULL,
        target_getdata = NULL,
        source_getdata = NULL,
        data_objects = list(),
        list_source = NULL,
        list_target = NULL,
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
    
    
    
    # ########################
    # # tab_config
    # ########################
    
    callModule(moduleConfigServer, "moduleConfig", rv, input_re=reactive({input}))
    
    observe({
        if (!is.null(rv$target_getdata) && !is.null(rv$source_getdata)){
            
            # hide load data button
            shinyjs::hide("moduleDashboard-dash_load_btn")
            
            # disable config page
            shinyjs::disable("moduleConfig-config_targetdb_rad")
            shinyjs::disable("moduleConfig-config_targetdb_dbname")
            shinyjs::disable("moduleConfig-config_targetdb_hostname")
            shinyjs::disable("moduleConfig-config_targetdb_port")
            shinyjs::disable("moduleConfig-config_targetdb_user")
            shinyjs::disable("moduleConfig-config_targetdb_password")
            shinyjs::disable("moduleConfig-config_targetdb_save_btn")
            shinyjs::disable("moduleConfig-config_targetdb_test_btn")
            shinyjs::disable("moduleConfig-config_sitename")
            shinyjs::disable("moduleConfig-config_sourcedir_in")
        }
    })
    
    observe({
        if (length(rv$data_objects) > 0){
            # render menu
            output$menu <- renderMenu({
                sidebarMenu(
                    menuItem("Review raw data", tabName = "tab_rawdata1", icon = icon("table")),
                    menuItem("Plot", tabName = "tab_visualizations", icon = icon("chart-line"))
                )
            })
            updateTabItems(session, "tabs", "tab_rawdata1")
        }
    })
    
    ########################
    # tab_dashboard
    ########################
    callModule(moduleDashboardServer, "moduleDashboard", rv, input_re=reactive({input}))
    
    
    ########################
    # tab_rawdata1
    ########################
    callModule(moduleRawdata1Server, "moduleRawdata1", rv, input_re=reactive({input}))
    
    ########################
    # tab_visualization
    ########################
    callModule(moduleVisualizationsServer, "moduleVisulizations", rv, input_re=reactive({input}))
    
    ########################
    # tab_mdr
    ########################
    callModule(moduleMDRServer, "moduleMDR", rv, input_re=reactive({input}))

})
