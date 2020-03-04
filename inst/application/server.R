# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2020 Universitätsklinikum Erlangen
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

shiny::shinyServer(
    function(input, output, session) {
        # define reactive values here
        rv <- shiny::reactiveValues(
            headless = FALSE,
            config_file = config_file,
            # mdr_filename = mdr_filename,
            use_env_credentials = use_env_credentials,
            utilspath = DQAstats::clean_path_name(utils_path),
            current_date = format(Sys.Date(), "%d. %B %Y", tz = "CET")
        )

        # read datamap email
        rv$datamap_email <- tryCatch(
            expr = {
                # if existing, set email address for data-map button
                out <- DQAstats::get_config(
                    config_file = paste0(utils_path, "/MISC/email.yml"),
                    config_key = "email"
                )
            }, error = function(e) {
                print(e)
                # otherwise set it to empty string
                out <- ""
            }, finally = function(f) {
                return(out)
            })

        # handle reset
        shiny::observeEvent(input$reset, {
            shinyjs::js$reset()
        })

        input_reactive <- reactive({
            input
        })

        # ########################
        # # tab_config
        # ########################

        shiny::callModule(DQAgui::module_config_server,
                          "moduleConfig",
                          rv,
                          input_re = input_reactive)

        shiny::observe({
            # first call (rv$target_getdata = TRUE and
            # rv$source_getdata = TRUE),
            # when load-data-button quality checks in
            # moduleDashboard are passed
            if (!is.null(rv$getdata_target) &&
                !is.null(rv$getdata_source)) {

                if (!isTRUE(rv$start)) {
                    # set active tab
                    shinydashboard::updateTabItems(
                        session = session,
                        inputId = "tabs",
                        selected = "tab_dashboard"
                    )
                }

                # hide load data button
                shinyjs::hide("moduleConfig-dash_load_btn")

                shinyjs::disable("moduleConfig-config_sourcedir_in")
                shinyjs::disable("moduleConfig-source_csv_presettings_list")
                shinyjs::disable("moduleConfig-source_csv_dir")
                shinyjs::disable("moduleConfig-source_tabs")
                shinyjs::disable("moduleConfig-source_pg_presettings_list")
                shinyjs::disable("moduleConfig-config_sourcedb_dbname")
                shinyjs::disable("moduleConfig-config_sourcedb_host")
                shinyjs::disable("moduleConfig-config_sourcedb_port")
                shinyjs::disable("moduleConfig-config_sourcedb_user")
                shinyjs::disable("moduleConfig-config_sourcedb_password")
                shinyjs::disable("moduleConfig-source_pg_test_connection")

                shinyjs::disable("moduleConfig-config_targetdir_in")
                shinyjs::disable("moduleConfig-target_csv_presettings_list")
                shinyjs::disable("moduleConfig-target_csv_dir")
                shinyjs::disable("moduleConfig-target_tabs")
                shinyjs::disable("moduleConfig-target_pg_presettings_list")
                shinyjs::disable("moduleConfig-config_targetdb_dbname")
                shinyjs::disable("moduleConfig-config_targetdb_host")
                shinyjs::disable("moduleConfig-config_targetdb_port")
                shinyjs::disable("moduleConfig-config_targetdb_user")
                shinyjs::disable("moduleConfig-config_targetdb_password")
                shinyjs::disable("moduleConfig-target_pg_test_connection")

                shinyjs::disable("moduleConfig-config_sitename")
                shinyjs::disable(
                    "moduleConfig-target_system_to_source_system_btn"
                )

                if (input$tabs == "tab_dashboard") {
                    rv$start <- TRUE
                }
            }
        })

        shiny::observe({
            req(rv$mdr)
            shinyjs::disable("moduleConfig-config_load_mdr")

            output$mdr <- shinydashboard::renderMenu({
                shinydashboard::sidebarMenu(shinydashboard::menuItem(
                    "DQ MDR",
                    tabName = "tab_mdr",
                    icon = icon("database")
                ))
            })
            shinydashboard::updateTabItems(
                session = session,
                inputId = "tabs",
                selected = "tab_config"
            )
        })

        shiny::observe({
            shiny::req(rv$report_created)

            # set end_time
            rv$end_time <- format(Sys.time(), usetz = T, tz = "CET")
            # calc time-diff
            rv$duration <-
                difftime(rv$end_time, rv$start_time, units = "mins")

            # render menu
            output$menu <- shinydashboard::renderMenu({
                shinydashboard::sidebarMenu(
                    #shinydashboard::menuItem("Review raw data",
                    #tabName = "tab_rawdata1", icon = icon("table")),
                    shinydashboard::menuItem(
                        text = "Descriptive Results",
                        tabName = "tab_descriptive",
                        icon = icon("table")
                    ),
                    shinydashboard::menuItem(
                        text = "Plausibility Checks",
                        tabName = "tab_plausibility",
                        icon = icon("check-circle"),
                        shinydashboard::menuSubItem(
                            text = "Atemporal Plausibility",
                            tabName = "tab_atemp_plausibility"
                        ),
                        shinydashboard::menuSubItem(
                            text = "Uniqueness Plausibility",
                            tabName = "tab_uniq_plausibility"
                        )
                    ),
                    shinydashboard::menuItem(
                        text = "Completeness",
                        tabName = "tab_completeness",
                        icon = icon("chart-line")
                    ),
                    #shinydashboard::menuItem("Visualizations",
                    #tabName = "tab_visualizations",
                    #icon = icon("chart-line")),
                    shinydashboard::menuItem(
                        text = "Reporting",
                        tabName = "tab_report",
                        icon = icon("file-alt")
                    )
                )
            })
            shinydashboard::updateTabItems(
                session = session,
                inputId = "tabs",
                selected = "tab_dashboard"
            )
        })


        observe({
            req(rv$datamap)

            # !!! trigger shinyjs from server.R only
            shinyjs::onclick(
                # https://stackoverflow.com/questions/27650331/adding-an-email-
                # button-in-shiny-using-tabletools-or-otherwise
                # https://stackoverflow.com/questions/27650331/adding-an-email-
                # button-in-shiny-using-tabletools-or-otherwise
                # https://stackoverflow.com/questions/37795760/r-shiny-add-
                # weblink-to-actionbutton
                # https://stackoverflow.com/questions/45880437/r-shiny-use-
                # onclick-option-of-actionbutton-on-the-server-side
                # https://stackoverflow.com/questions/45376976/use-
                # actionbutton-to-send-email-in-rshiny
                id = "moduleDashboard-dash_send_datamap_btn",
                expr =  {
                    rv$send_datamap <- button_send_datamap(rv)
                    shinyjs::runjs(rv$send_datamap)
                }
            )
        })

        observe({
            req(rv$datamap)
            # To allow only one export, disable button afterwards:
            if (is.null(rv$send_btn_disabled)) {
                if (isTRUE(rv$datamap$exported)) {
                    updateActionButton(
                        session = session,
                        inputId = "moduleDashboard-dash_send_datamap_btn",
                        label = "Datamap successfully sent",
                        # so don't send it again
                        icon = icon("check")
                    )
                    shinyjs::disable(
                        "moduleDashboard-dash_send_datamap_btn"
                    )
                    rv$send_btn_disabled <- TRUE
                }
            }
        })

        ########################
        # tab_dashboard
        ########################
        shiny::callModule(DQAgui::module_dashboard_server,
                          "moduleDashboard",
                          rv,
                          input_re = input_reactive)

        ########################
        # tab_descriptive
        ########################
        shiny::callModule(DQAgui::module_descriptive_server,
                          "moduleDescriptive",
                          rv,
                          input_re = input_reactive)

        ########################
        # tab_plausibility
        ########################
        shiny::callModule(DQAgui::module_atemp_pl_server,
                          "moduleAtempPlausibility",
                          rv,
                          input_re = input_reactive)
        shiny::callModule(DQAgui::module_uniq_plaus_server,
                          "moduleUniquePlausibility",
                          rv,
                          input_re = input_reactive)

        ########################
        # tab_completeness
        ########################
        shiny::callModule(DQAgui::module_completeness_server,
                          "moduleCompleteness",
                          rv,
                          input_re = input_reactive)

        # ########################
        # # tab_visualization
        # ########################
        #% shiny::callModule(module_visualizations_server,
        #%                   "moduleVisulizations",
        #%                   rv,
        #%                   input_re = input_reactive)

        ########################
        # tab_report
        ########################
        shiny::callModule(DQAgui::module_report_server,
                          "moduleReport",
                          rv,
                          input_re = input_reactive)

        ########################
        # tab_mdr
        ########################
        shiny::callModule(DQAgui::module_mdr_server,
                          "moduleMDR",
                          rv,
                          input_re = input_reactive)

    })
