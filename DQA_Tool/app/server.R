# (c) 2019 Lorenz Kapsner
shinyServer(function(input, output, session) {
    
    # define reactive values here
    rv <- reactiveValues(
        started = NULL,
        mdr = NULL,
        target_keys = NULL,
        source_keys = NULL,
        sourcefiledir = NULL,
        sitenames = NULL,
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
        dash_summary_source = summaryTable()
    )
    
    
    # run onStart here
    onStart(session, rv, input, output)
    
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
            shinyjs::disable("moduleConfig-config_targetdb_host")
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
        req(rv$report_created)
        
        # set end.time
        rv$end.time <- Sys.time()
        # calc time-diff
        rv$duration <- difftime(rv$end.time, rv$start.time, units = "mins")
        
        # TODO one could remove raw-data here
        # rv$list_source <- NULL
        # rv$list_target <- NULL
        # gc()
        
        # render menu
        output$menu <- renderMenu({
            sidebarMenu(
                menuItem("Review raw data", tabName = "tab_rawdata1", icon = icon("table")),
                menuItem("Results Numerical Variables", tabName = "tab_numerical", icon = icon("table")),
                menuItem("Results Categorical Variables", tabName = "tab_categorical", icon = icon("table")),
                menuItem("Plausibility Checks", tabName = "tab_plausibility", icon = icon("check-circle")),
                menuItem("Visualizations", tabName = "tab_visualizations", icon = icon("chart-line")),
                menuItem("Reporting", tabName = "tab_report", icon = icon("file-alt"))
            )
        })
        updateTabItems(session, "tabs", "tab_dashboard")
        
        # for debugging purposes
        numerical_out <<- rv$dqa_numerical_results
        categorical_out <<- rv$dqa_categorical_results
        plausi_out <<- rv$dqa_plausibility_results
        source_data <<- rv$list_source
        target_data <<- rv$list_target
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
    # tab_numerical
    ########################
    callModule(moduleNumericalServer, "moduleNumerical", rv, input_re=reactive({input}))
    
    ########################
    # tab_categorical
    ########################
    callModule(moduleCategoricalServer, "moduleCategorical", rv, input_re=reactive({input}))
    
    ########################
    # tab_plausibility
    ########################
    callModule(modulePlausibilityServer, "modulePlausibility", rv, input_re=reactive({input}))
    
    ########################
    # tab_visualization
    ########################
    callModule(moduleVisualizationsServer, "moduleVisulizations", rv, input_re=reactive({input}))
    
    ########################
    # tab_report
    ########################
    callModule(moduleReportServer, "moduleReport", rv, input_re=reactive({input}))
    
    ########################
    # tab_mdr
    ########################
    callModule(moduleMDRServer, "moduleMDR", rv, input_re=reactive({input}))

})
