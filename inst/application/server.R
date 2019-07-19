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

shiny::shinyServer(function(input, output, session) {

    # define reactive values here
    rv <- shiny::reactiveValues(
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
        dash_summary_target = NULL,
        dash_summary_source = NULL
    )


    # run onStart here
    onStart(session, rv, input, output)

    # handle reset
    shiny::observeEvent(input$reset, {
        shinyjs::js$reset()
    })



    # ########################
    # # tab_config
    # ########################

    shiny::callModule(moduleConfigServer, "moduleConfig", rv, input_re=shiny::reactive({input}))

    shiny::observe({
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

    shiny::observe({
        shiny::req(rv$report_created)

        # set end.time
        rv$end.time <- Sys.time()
        # calc time-diff
        rv$duration <- difftime(rv$end.time, rv$start.time, units = "mins")

        # TODO one could remove raw-data here
        # rv$list_source <- NULL
        # rv$list_target <- NULL
        # gc()

        # render menu
        output$menu <- shinydashboard::renderMenu({
            shinydashboard::sidebarMenu(
                shinydashboard::menuItem("Review raw data", tabName = "tab_rawdata1", icon = icon("table")),
                shinydashboard::menuItem("Descriptive Results", tabName = "tab_descriptive", icon = icon("table")),
                shinydashboard::menuItem("Plausibility Checks", tabName = "tab_plausibility", icon = icon("check-circle"),
                                         shinydashboard::menuSubItem("Atemporal Plausibility", tabName = "tab_atemp_plausibility"),
                                         shinydashboard::menuSubItem("Uniqueness Plausibility", tabName = "tab_unique_plausibility")),
                shinydashboard::menuItem("Visualizations", tabName = "tab_visualizations", icon = icon("chart-line")),
                shinydashboard::menuItem("Reporting", tabName = "tab_report", icon = icon("file-alt"))
            )
        })
        shinydashboard::updateTabItems(session, "tabs", "tab_dashboard")

        # for debugging purposes
        descriptive_results <<- rv$dqa_descriptive_results
        plausi_out <<- rv$dqa_plausibility_results
        conformance_out <<- rv$conformance
        source_data <<- rv$list_source
        target_data <<- rv$list_target
    })

    ########################
    # tab_dashboard
    ########################
    shiny::callModule(moduleDashboardServer, "moduleDashboard", rv, input_re=reactive({input}))


    ########################
    # tab_rawdata1
    ########################
    shiny::callModule(moduleRawdata1Server, "moduleRawdata1", rv, input_re=reactive({input}))

    ########################
    # tab_descriptive
    ########################
    shiny::callModule(moduleDescriptiveServer, "moduleDescriptive", rv, input_re=reactive({input}))

    ########################
    # tab_plausibility
    ########################
    shiny::callModule(moduleAtempPlausibilityServer, "moduleAtempPlausibility", rv, input_re=reactive({input}))
    shiny::callModule(moduleUniquePlausibilityServer, "moduleUniquePlausibility", rv, input_re=reactive({input}))

    ########################
    # tab_visualization
    ########################
    shiny::callModule(moduleVisualizationsServer, "moduleVisulizations", rv, input_re=reactive({input}))

    ########################
    # tab_report
    ########################
    shiny::callModule(moduleReportServer, "moduleReport", rv, input_re=reactive({input}))

    ########################
    # tab_mdr
    ########################
    shiny::callModule(moduleMDRServer, "moduleMDR", rv, input_re=reactive({input}))

})
