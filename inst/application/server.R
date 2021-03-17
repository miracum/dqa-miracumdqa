# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2021 Universitätsklinikum Erlangen
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
            # mdr_filename = mdr_filename,
            log = list(logfile_dir = DIZutils::clean_path_name(logfile_dir)),
            utilspath = DIZutils::clean_path_name(utils_path),
            current_date = format(Sys.Date(), "%d. %B %Y", tz = "CET"),
            parallel = parallel,
            ncores = ncores
        )

        shiny::observe({
            if (is.null(rv$finished_onstart)) {

                # Clean old connections (e.g. after reloading the app):
                DIZutils::close_all_connections(
                    logfile_dir = rv$log$logfile_dir,
                    headless = rv$headless
                )

                # Create new logfile:
                DIZutils::cleanup_old_logfile(
                    logfile_dir = rv$log$logfile_dir
                )

                # feedback directories
                DIZutils::feedback(
                    print_this = paste0(
                        "Logfile dir: ",
                        rv$log$logfile_dir
                    ),
                    logfile_dir = rv$log$logfile_dir,
                    headless = rv$headless
                )
                DIZutils::feedback(
                    print_this = paste0(
                        "Utils path: ",
                        rv$utilspath
                    ),
                    logfile_dir = rv$log$logfile_dir,
                    headless = rv$headless
                )
                DIZutils::feedback(
                    print_this = paste0(
                        "MDR filename: ",
                        rv$mdr_filename
                    ),
                    logfile_dir = rv$log$logfile_dir,
                    headless = rv$headless
                )

                # read datamap email
                rv$datamap_email <- tryCatch(
                    expr = {
                        # if existing, set email address for data-map button
                        out <- DIZutils::get_config(
                            config_file = paste0(
                                utils_path, "/MISC/email.yml"
                            ),
                            config_key = "email",
                            logfile_dir = rv$log$logfile_dir,
                            headless = rv$headless
                        )
                    }, error = function(e) {
                        print(e)
                        # otherwise set it to empty string
                        out <- ""
                    }, finally = function(f) {
                        return(out)
                    })

                DQAstats::parallel(
                    parallel = rv$parallel,
                    logfile_dir = rv$log$logfile_dir,
                    ncores = rv$ncores
                )

                rv$finished_onstart <- TRUE
            }
        })

        # handle reset
        shiny::observeEvent(input$reset, {
            DIZutils::feedback(
                print_this = "\U2304",
                logfile_dir = rv$log$logfile_dir,
                headless = rv$headless
            )
            DIZutils::feedback(
                print_this = "############ APP WAS RESETTED ############",
                findme = "9c57ce125a",
                logfile_dir = rv$log$logfile_dir,
                headless = rv$headless
            )
            DIZutils::feedback(
                print_this = "\U2303",
                logfile_dir = rv$log$logfile_dir,
                headless = rv$headless
            )
            DIZutils::close_all_connections(
                logfile_dir = rv$log$logfile_dir,
                headless = rv$headless
            )
            ## Old (until 2021-03-15):
            # shinyjs::js$reset()
            ## New (since 2021-03-15):
            session$reload()

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
                shinyjs::disable("moduleConfig-select_dqa_assessment_variables")
                shinyjs::disable("moduleConfig-select_all_assessment_variables")
                shinyjs::disable("moduleConfig-select_no_assessment_variables")

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


        shiny::observe({
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

        shiny::observe({
            req(rv$datamap)
            # To allow only one export, disable button afterwards:
            if (is.null(rv$send_btn_disabled)) {
                if (isTRUE(rv$datamap$exported)) {
                    # so don't send it again
                    updateActionButton(
                        session = session,
                        inputId = "moduleDashboard-dash_send_datamap_btn",
                        label = "Datamap successfully sent",
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

        ########################
        # tab_log
        ########################
        shiny::callModule(DQAgui::module_log_server,
                          "moduleLog",
                          rv,
                          input_re = input_reactive)

        shiny::observe({
            if (input$tabs == "tab_log") {
                updateSelectInput(
                    session = session,
                    inputId = "moduleLog-old_logfiles_list",
                    selected = "logfile.log"
                )
                shinyjs::click("moduleLog-moduleLog_scrolldown_btn")
            }
        })
    })
