# by Lorenz Kapsner
shinyServer(function(input, output, session) {
    
    # define reactive values here
    rv <- reactiveValues(
        started = NULL,
        mdr = NULL,
        target_keys = NULL,
        source_keys = NULL,
        file = NULL,
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
        if (length(rv$data_objects) > 0){
            # render menu
            output$menu <- renderMenu({
                sidebarMenu(
                    menuItem("Review raw data", tabName = "tab_rawdata1", icon = icon("table")),
                    menuItem("Results Numerical Variables", tabName = "tab_numerical", icon = icon("table")),
                    menuItem("Results Categorical Variables", tabName = "tab_categorical", icon = icon("table")),
                    menuItem("Plot", tabName = "tab_visualizations", icon = icon("chart-line")),
                    menuItem("Reporting", tabName = "tab_report", icon = icon("file-alt"))
                )
            })
            #updateTabItems(session, "tabs", "tab_rawdata1")
            
            # for debugging purposes
            numerical_out <<- rv$dqa_numerical_results
            categorical_out <<- rv$dqa_categorical_results
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
    # tab_numerical
    ########################
    callModule(moduleNumericalServer, "moduleNumerical", rv, input_re=reactive({input}))
    
    ########################
    # tab_categorical
    ########################
    callModule(moduleCategoricalServer, "moduleCategorical", rv, input_re=reactive({input}))
    
    ########################
    # tab_visualization
    ########################
    callModule(moduleVisualizationsServer, "moduleVisulizations", rv, input_re=reactive({input}))
    
    ########################
    # tab_report
    ########################
    callModule(moduleReportServer, "moduleReport", rv, input_re=reactive({input}))
    
    observeEvent(input[["moduleReport-create_report"]], {
        shinyjs::disable("moduleReport-create_report")
        
        withProgress(
            message = paste0("Creating report ..."), value = 0, {
                incProgress(1/1, detail = "... working hard to create pdf ...")
                # create pdf from shiny:
                # https://stackoverflow.com/questions/34029611/how-to-use-objects-from-global-environment-in-rstudio-markdown
                knitr::knit(input="./_utilities/RMD/DQA_report.Rmd", output=paste0(tempdir(), "/DQA_report.md"), encoding = "UTF-8")
                # copy header-folder to tempdir to make files available for the next command
                file.copy("./_utilities/RMD/_header", tempdir(), recursive=TRUE)
                rmarkdown::render(input=paste0(tempdir(), "/DQA_report.md"), output_file = paste0(tempdir(), "/DQA_report.pdf"), encoding = "UTF-8")
            })
        
        # workaround to get conditionalpanel in moduleReport working!
        output$reportCreated <- reactive({
            return(TRUE)
        })
        outputOptions(output, 'reportCreated', suspendWhenHidden=FALSE)
    })
    
    ########################
    # tab_mdr
    ########################
    callModule(moduleMDRServer, "moduleMDR", rv, input_re=reactive({input}))

})
