# DQAgui - A graphical user interface (GUI) to the functions implemented in the
# R package 'DQAstats'.
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


#' @title module_config_server
#'
#' @param input Shiny server input object
#' @param output Shiny server output object
#' @param session Shiny session object
#' @param rv The global 'reactiveValues()' object, defined in server.R
#' @param input_re The Shiny server input object, wrapped into a reactive
#'   expression: input_re = reactive({input})
#'
#' @export
#'
# module_config_server
module_config_server <-
  function(input, output, session, rv, input_re) {
    # filepath roots dir
    roots <- c(home = "/home/")

    # If source-csv-path-button is clicked, read the path and save it:
    # root-folder of shinyFiles::shinyDirChoose
    shinyFiles::shinyDirChoose(
      input = input,
      id = "config_sourcedir_in",
      roots = roots,
      session = session
    )

    shinyFiles::shinyDirChoose(
      input = input,
      id = "config_targetdir_in",
      roots = roots,
      session = session
    )

    # observe click button event
    observeEvent(
      eventExpr = input$config_sourcedir_in,
      handlerExpr = {
        rv$csv_dir_src_clicked <- FALSE
        rv$csv_dir_src <- as.character(DQAstats::clean_path_name(
          shinyFiles::parseDirPath(
            roots = roots,
            selection = input$config_sourcedir_in
          )))
        rv$source$settings$dir <- rv$csv_dir_src

        if (!identical(rv$source$settings$dir, character(0)) &&
            !is.null(rv$source$settings$dir) &&
            rv$source$settings$dir != "") {
          # workaround to tell ui, that it is there
          output$source_csv_dir <- reactive({
            DQAgui::feedback(paste0("Source file dir: ",
                            rv$source$settings$dir), findme = "ad440c9fcb")
            paste(rv$source$settings$dir)
          })
          outputOptions(output, "source_csv_dir", suspendWhenHidden = FALSE)
          rv$source$system_name <-
            input_re()[["moduleConfig-source_csv_presettings_list"]]
          rv$source$system_type <- "csv"
          output$source_system_feedback_txt <-
            renderText({
              DQAgui::feedback_txt(system = "CSV", type = "source")
            })
        }
      }
    )

    observeEvent(
      eventExpr = input$config_targetdir_in,
      handlerExpr = {
        rv$csv_dir_tar_clicked <- FALSE
        rv$csv_dir_tar <- as.character(DQAstats::clean_path_name(
          shinyFiles::parseDirPath(
            roots = roots,
            selection = input$config_targetdir_in
          )))
        rv$target$settings$dir <- rv$csv_dir_tar

        if (!identical(rv$target$settings$dir, character(0)) &&
            !is.null(rv$target$settings$dir) &&
            rv$target$settings$dir != "") {
          # workaround to tell ui, that it is there
          output$target_csv_dir <- reactive({
            DQAgui::feedback(paste0("Target file dir: ",
                            rv$target$settings$dir), findme = "6f18c181e5")
            paste(rv$target$settings$dir)
          })
          outputOptions(output, "target_csv_dir", suspendWhenHidden = FALSE)
          rv$target$system_name <-
            input_re()[["moduleConfig-target_csv_presettings_list"]]
          rv$target$system_type <- "csv"
          output$target_system_feedback_txt <-
            renderText({
              DQAgui::feedback_txt(system = "CSV", type = "target")
            })
        }
      }
    )

    # observe source file directory
    observe({
      req(rv$csv_dir_src)

      if (isFALSE(rv$csv_dir_src_clicked)) {
        rv$csv_dir_src_clicked <- TRUE

        if (!identical(rv$csv_dir_src, character(0)) &&
            !is.null(rv$csv_dir_src) &&
            rv$csv_dir_src != "") {
          rv$source$settings <- NULL
          rv$source$settings$dir <- rv$csv_dir_src
        } else {
          # New source path is empty - Backup old path if existing:
          path_old_tmp1 <- rv$source$settings$dir
          if (!identical(path_old_tmp1, character(0)) &&
              !is.null(path_old_tmp1) &&
              path_old_tmp1 != "") {
            # Delete all old settings:
            rv$source$settings <- NULL
            # Re-assign the old path:
            rv$source$settings$dir <- path_old_tmp1
          } else {
            # No old path exists so delete all settings:
            rv$source$settings <- NULL
          }
        }
      }
    })

    # observe target file directory
    observe({
      req(rv$csv_dir_tar)

      if (isFALSE(rv$csv_dir_tar_clicked)) {
        rv$csv_dir_tar_clicked <- TRUE

        if (!identical(rv$csv_dir_tar, character(0)) &&
            !is.null(rv$csv_dir_tar) &&
            rv$csv_dir_tar != "") {
          rv$target$settings <- NULL
          rv$target$settings$dir <- rv$csv_dir_tar
        } else {
          # New target path is empty - Backup old path if existing:
          path_old_tmp1 <- rv$target$settings$dir
          if (!identical(path_old_tmp1, character(0)) &&
              !is.null(path_old_tmp1) &&
              path_old_tmp1 != "") {
            # Delete all old settings:
            rv$target$settings <- NULL
            # Re-assign the old path:
            rv$target$settings$dir <- path_old_tmp1
          } else {
            # No old path exists so delete all settings:
            rv$target$settings <- NULL
          }
        }
      }
    })

    # load mdr
    observeEvent(
      eventExpr = input_re()[["moduleConfig-config_load_mdr"]],
      handlerExpr = {
        if (is.null(rv$mdr)) {
          DQAgui::feedback("Reading MDR ...", findme = "b9c2844de8")
          DQAgui::feedback(paste0("MDR-Filename:", rv$mdr_filename),
                           findme = "53cbff1151")
          DQAgui::feedback(paste0("rv$utilspath:", rv$utilspath),
                           findme = "31439a4a92")

          withProgress(message = "Loading MDR", value = 0, {
            incProgress(
              1 / 1,
              detail = "... from local file ...")
            # read MDR
            rv$mdr <-
              DQAstats::read_mdr(utils_path = rv$utilspath,
                                 mdr_filename = rv$mdr_filename)
          })
          stopifnot(data.table::is.data.table(rv$mdr))

          ## Read in the settings
          # - Determine the different systems from mdr:
          vec <-
            c("source_table_name",
              "source_system_name",
              "source_system_type")
          rv$systems <- unique(rv$mdr[, vec, with = F])
          DQAgui::feedback("Different systems found in MDR:",
                           findme = "4451da82ad")

          # - Read the settings for all these systems:
          unique_systems <-
            rv$systems[!is.na(get("source_system_name")),
                       unique(get("source_system_name"))]
          rv$settings <-
            lapply(unique_systems, function(x)
              DQAstats::get_config(config_file = rv$config_file,
                                   config_key = tolower(x)))

          # - Different system-types:
          rv$system_types <-
            rv$systems[!is.na(get("source_system_type")),
                       unique(get("source_system_type"))]

          DQAgui::feedback(rv$system_types,
                   prefix = "System type ",
                   findme = "9aec84fcca")

          if (!("csv" %in% tolower(rv$system_types))) {
            # Remove CSV-Tabs:
            DQAgui::feedback("Removing csv-tab from source ...",
                             findme = "3c2f368001")
            removeTab(inputId = "source_tabs", target = "CSV")

            DQAgui::feedback("Removing csv-tab from target ...",
                             findme = "337b20a126")
            removeTab(inputId = "target_tabs", target = "CSV")
          } else {
            csv_system_names <-
              rv$systems[get("source_system_type") == "csv" &
                           !is.na(get("source_system_name")),
                         unique(get("source_system_name"))]
            DQAgui::feedback(csv_system_names,
                     prefix = "csv_system_names: ",
                     findme = "5a083a3d53")

            if (length(csv_system_names) > 0) {
              # Show buttons to prefill diff. systems presettings:
              # - Add a button/choice/etc. for each system:
              updateSelectInput(session = session,
                                inputId = "source_csv_presettings_list",
                                choices = csv_system_names)
              updateSelectInput(session = session,
                                inputId = "target_csv_presettings_list",
                                choices = csv_system_names)
            }
          }
          if (!("postgres" %in% tolower(rv$system_types))) {
            # Remove Postgres-Tabs:
            DQAgui::feedback("Removing postgres-tab from source ...",
                             findme = "de66c75fe4")
            removeTab(inputId = "source_tabs", target = "PostgreSQL")

            DQAgui::feedback("Removing postgres-tab from target ...",
                             findme = "26501edb68")
            removeTab(inputId = "target_tabs", target = "PostgreSQL")
          } else{
            # Fill the tab with presettings
            # - filter for all system_names with
            #% system_type == postgres
            #% select source_system_name from
            #% rv$systems where source_system_type == postgres
            #% GROUP BY source_system_name
            postgres_system_names <-
              rv$systems[get("source_system_type") == "postgres" &
                           !is.na(get("source_system_name")),
                         unique(get("source_system_name"))]
            DQAgui::feedback(postgres_system_names,
                     prefix = "postgres_system_names: ",
                     findme = "be136f5ab6")

            if (length(postgres_system_names) > 0) {
              # Show buttons to prefill diff. systems presettings:
              # - Add a button/choice/etc. for each system:
              updateSelectInput(session = session,
                                inputId = "source_pg_presettings_list",
                                choices = postgres_system_names)
              updateSelectInput(session = session,
                                inputId = "target_pg_presettings_list",
                                choices = postgres_system_names)
            }
          }

          # Store the system-types in output-variable to only
          # show these tabs on the config page:
          output$system_types <- reactive({
            rv$system_types
          })
          outputOptions(output,
                        "system_types",
                        suspendWhenHidden = FALSE)

          # workaround to tell ui, that mdr is there
          output$mdr_present <- reactive({
            return(TRUE)
          })
          outputOptions(output,
                        "mdr_present",
                        suspendWhenHidden = FALSE)

          # workaround to tell ui, that mdr is there
          output$source_system_type <- reactive({
            return(input_re()
                   [["moduleConfig-config_source_system_type"]])
          })
          outputOptions(output,
                        "source_system_type",
                        suspendWhenHidden = FALSE)
        }
      })


    # If the "load presets"-button was pressed, startload & show the presets:
    # observeEvent(input$source_pg_presettings_btn, {
    observeEvent(input$source_pg_presettings_list, {
      DQAgui::feedback(
        paste0(
          "Input-preset ",
          input$source_pg_presettings_list,
          " was chosen as SOURCE.",
          " Loading presets ..."
        ), findme = "e9832b3092"
      )
      config_stuff <- DQAstats::get_config(
        config_file = rv$config_file,
        config_key = tolower(input$source_pg_presettings_list)
      )
      DQAgui::feedback(paste(
        "Loaded successfully.",
        "Filling presets to global rv-object and UI ..."
      ), findme = "3c9136d49f")
      if (length(config_stuff) != 0) {
        updateTextInput(session = session,
                        inputId = "config_sourcedb_dbname",
                        value = config_stuff[["dbname"]])
        updateTextInput(session = session,
                        inputId = "config_sourcedb_host",
                        value = config_stuff[["host"]])
        updateTextInput(session = session,
                        inputId = "config_sourcedb_port",
                        value = config_stuff[["port"]])
        updateTextInput(session = session,
                        inputId = "config_sourcedb_user",
                        value = config_stuff[["user"]])
        updateTextInput(session = session,
                        inputId = "config_sourcedb_password",
                        value = config_stuff[["password"]])
      } else{
        updateTextInput(session = session,
                        inputId = "config_sourcedb_dbname",
                        value = "")
        updateTextInput(session = session,
                        inputId = "config_sourcedb_host",
                        value = "")
        updateTextInput(session = session,
                        inputId = "config_sourcedb_port",
                        value = "")
        updateTextInput(session = session,
                        inputId = "config_sourcedb_user",
                        value = "")
        updateTextInput(session = session,
                        inputId = "config_sourcedb_password",
                        value = "")
      }
    })

    #observeEvent(input$target_pg_presettings_btn, {
    observeEvent(input$target_pg_presettings_list, {
      DQAgui::feedback(
        paste0(
          "Input-preset ",
          input$target_pg_presettings_list,
          " was chosen as TARGET",
          " Loading presets ..."
        ), findme = "d603f8127a"
      )
      config_stuff <- DQAstats::get_config(
        config_file = rv$config_file,
        config_key = tolower(input$target_pg_presettings_list)
      )
      DQAgui::feedback(paste(
        "Loaded successfully.",
        "Filling presets to global rv-object and UI ..."
      ), findme = "fa908f0035")
      if (length(config_stuff) != 0) {
        updateTextInput(session = session,
                        inputId = "config_targetdb_dbname",
                        value = config_stuff[["dbname"]])
        updateTextInput(session = session,
                        inputId = "config_targetdb_host",
                        value = config_stuff[["host"]])
        updateTextInput(session = session,
                        inputId = "config_targetdb_port",
                        value = config_stuff[["port"]])
        updateTextInput(session = session,
                        inputId = "config_targetdb_user",
                        value = config_stuff[["user"]])
        updateTextInput(session = session,
                        inputId = "config_targetdb_password",
                        value = config_stuff[["password"]])
      } else{
        updateTextInput(session = session,
                        inputId = "config_targetdb_dbname",
                        value = "")
        updateTextInput(session = session,
                        inputId = "config_targetdb_host",
                        value = "")
        updateTextInput(session = session,
                        inputId = "config_targetdb_port",
                        value = "")
        updateTextInput(session = session,
                        inputId = "config_targetdb_user",
                        value = "")
        updateTextInput(session = session,
                        inputId = "config_targetdb_password",
                        value = "")
      }
    })

    observeEvent(input$source_pg_test_connection, {
      rv$source$settings <-
        get_db_settings(input = input_re(), target = F)

      if (!is.null(rv$source$settings)) {
        rv$source$db_con <- DQAstats::test_db(settings = rv$source$settings,
                                              headless = rv$headless,
                                              timeout = 2)

        if (!is.null(rv$source$db_con)) {
          DQAgui::feedback(
            paste0(
              "\nDB connection for ",
              input$source_pg_presettings_list,
              " successfully established\n"
            ), findme = "e35eaa306e"
          )
          showNotification(
            paste0(
              "\U2714 Connection to ",
              input$source_pg_presettings_list,
              " established"
            )
          )
          rv$source$system_name <- input$source_pg_presettings_list
          rv$source$system_type <- "postgres"
          output$source_system_feedback_txt <-
            renderText({
              DQAgui::feedback_txt(system = "PostgreSQL", type = "source")
            })
        } else {
          showNotification(paste0(
            "\U2718 Connection to ",
            input$source_pg_presettings_list,
            " failed"
          ))
          rv$source$system <- ""
        }
      }

    })

    observeEvent(input$target_pg_test_connection, {
      rv$target$settings <-
        get_db_settings(input = input_re(), target = T)

      if (!is.null(rv$target$settings)) {
        rv$target$db_con <- DQAstats::test_db(settings = rv$target$settings,
                                              headless = rv$headless,
                                              timeout = 2)

        if (!is.null(rv$target$db_con)) {
          DQAgui::feedback(
            paste0(
              "\nDB connection for ",
              input$target_pg_presettings_list,
              " successfully established\n"
            ), findme = "1dc68937b8"
          )
          showNotification(
            paste0(
              "\U2714 Connection to ",
              input$target_pg_presettings_list,
              " established"
            )
          )
          rv$target$system_name <- input$target_pg_presettings_list
          rv$target$system_type <- "postgres"
          output$target_system_feedback_txt <-
            renderText({
              DQAgui::feedback_txt(system = "PostgreSQL", type = "target")
            })
        } else {
          showNotification(paste0(
            "\U2718 Connection to ",
            input$target_pg_presettings_list,
            " failed"
          ))
          rv$target$system <- ""
        }
      }
    })

    observeEvent(input$target_system_to_source_system_btn, {
      if (isTRUE(rv$target_is_source)) {
        ## Target was == source but should become different now:
        rv$target_is_source <- F
        rv$target <- NULL
        output$target_system_feedback_txt <- NULL
        # Show target-settings-tabs again:
        showTab(inputId = "target_tabs", target = "CSV")
        showTab(inputId = "target_tabs", target = "PostgreSQL")
        # Change button-label:
        updateActionButton(session, "target_system_to_source_system_btn",
                           label = " Set TARGET = SOURCE")
        # Feedback to the console:
        DQAgui::feedback("Target != source now.",
                 findme = "ec51b122ee")
      } else {
        ## Target != source and should become equal:
        # Change button-label:
        updateActionButton(session, "target_system_to_source_system_btn",
                           label = "Allow custom settings for target")
        # Hide target-setting-tabs:
        hideTab(inputId = "target_tabs", target = "CSV")
        hideTab(inputId = "target_tabs", target = "PostgreSQL")
        # Assign source-values to target:
        rv <- DQAgui::set_target_equal_to_source(rv)
        # Set internal flag that target == source:
        rv$target_is_source <- T
        # Show feedback-box in the UI:
        output$target_system_feedback_txt <-
          renderText({
            DQAgui::feedback_txt(system = "The source system", type = "target")
          })
        # Feedback to the console:
        DQAgui::feedback("Target == source now.",
                 findme = "94d3a2090c")
      }
    })

    observe({
      if (is.null(rv$sitenames)) {
        # check, if user has provided custom site names
        rv$sitenames <- tryCatch({
          outlist <- jsonlite::fromJSON(
            paste0(rv$utilspath, "/MISC/sitenames.JSON")
          )
          outlist
        }, error = function(e) {
          outlist <- list("undefined" = "undefined")
          outlist
          # TODO instead of dropdown menu, render text input field in the
          # case, users have not provided sitenames. This allows them
          # to specify a name of the DQA session (which will be included
          # into the report's title)
        }, finally = function(f) {
          return(outlist)
        })

        updateSelectInput(
          session,
          "config_sitename",
          choices = rv$sitenames,
          selected = ifelse(!is.null(rv$sitename),
                            rv$sitename,
                            character(0))
        )
      }
    })


    observeEvent(
      input_re()[["moduleConfig-dash_load_btn"]], {
        # The button is on "moduleConfig".
        # This tab here will be set active below if all inputs are valid.

        # Error flag: If an error occurs, the flag will be set to true
        # and the main calculation won't start:
        error_tmp <- F

        # check, if mdr is present. without mdr, we cannot perform any
        # further operations
        if (is.null(rv$mdr)) {
          DQAgui::feedback(
            "No MDR found. Please provide a metadata repository (MDR).",
            type = "Warning",
            findme = "1dc68937b8"
          )
          error_tmp <- T
          # mdr is present:
        } else {
          # check if sitename is present
          if (nchar(input_re()[["moduleConfig-config_sitename"]]) < 2 ||
              any(grepl("\\s", input_re()[["moduleConfig-config_sitename"]]))) {
            # site name is missing:
            shiny::showModal(modalDialog(
              title = "Invalid values",
              paste0(
                "No empty strings or spaces allowed in ",
                "the site name configuration."
              )
            ))
            error_tmp <- T
          } else {
            # site name is present:
            rv$sitename <- input_re()[["moduleConfig-config_sitename"]]
          }

          # If target should be identical to source, set it here again:
          if (isTRUE(rv$target_is_source)) {
            rv <- DQAgui::set_target_equal_to_source(rv)
          }

          DQAgui::feedback(paste0("Source system is ", rv$source$system_name),
                   findme = "1d61685355")
          DQAgui::feedback(paste0("Target system is ", rv$target$system_name),
                   findme = "eaf72ed747")
        }


        if (DQAgui::validate_inputs(rv) && !error_tmp) {
          # set flags to inactivate config-widgets and start loading of
          # data
          rv$getdata_target <- TRUE
          rv$getdata_source <- TRUE

          if (!dir.exists(paste0(tempdir(), "/_settings/"))) {
            dir.create(paste0(tempdir(), "/_settings/"))
          }

          # save user settings
          writeLines(
            jsonlite::toJSON(
              list(
                "source_system" = rv$source$settings,
                "target_system" = rv$target$settings,
                "site_name" = rv$sitename
              ),
              pretty = T,
              auto_unbox = F
            ),
            paste0(tempdir(), "/_settings/global_settings.JSON")
          )
        }
      })
  }

#' @title module_config_ui
#'
#' @param id A character. The identifier of the shiny object
#'
#' @export
#'
# module_config_ui
module_config_ui <- function(id) {
  ns <- NS(id)

  tagList(
    fluidRow(
      column(
        9,
        ## This will be displayed after the MDR is loaded successfully:
        conditionalPanel(
          condition =
            "typeof output['moduleConfig-system_types'] !== 'undefined'",
          box(
            title = "Sitename",
            selectInput(
              ns("config_sitename"),
              "Please enter the name of your site",
              selected = F,
              choices = NULL,
              multiple = F
            ),
            width = 12
          ),
          box(
            title =  "SOURCE settings",
            width = 6,
            #solidHeader = TRUE,
            tabBox(
              # The id lets us use input$source_tabs
              # on the server to find the current tab
              id = ns("source_tabs"),
              width = 12,
              # selected = "PostgreSQL",
              tabPanel(
                # ATTENTION: If you change the title, you also have to change
                # the
                # corresponding part above for the "source == source" button
                # reaction. Otherwise the tabs won't hide/show up anymore.
                # >> ATTENTION <<
                title = "CSV",
                # >> ATTENTION << for title. See above.
                id = ns("source_tab_csv"),
                h4("Source CSV Upload"),
                box(
                  title = "Available CSV-Systems",
                  # background = "blue",
                  # solidHeader = TRUE,
                  width = 12,
                  selectInput(
                    # This will be filled in the server part.
                    inputId = ns("source_csv_presettings_list"),
                    label = NULL,
                    choices = NULL,
                    selected = NULL
                  ),
                  style = "text-align:center;"
                ),
                div(
                  paste(
                    "Please choose the directory of your",
                    "\u00A7",
                    "21 source data in csv format (default: '/home/input')."
                  )
                ),
                br(),
                # If the path is already set, display it
                conditionalPanel(
                  condition = paste0(
                    "typeof ",
                    "output['moduleConfig-source_csv_dir']",
                    " !== 'undefined'"
                  ),
                  verbatimTextOutput(ns("source_csv_dir")),
                  style = "text-align:center;"
                ),
                br(),

                # If there is no path set yet: Display the button to choose it
                shinyFiles::shinyDirButton(
                  id = ns("config_sourcedir_in"),
                  label = "Source Dir",
                  title = "Please select the source directory",
                  buttonType = "default",
                  icon = icon("folder"),
                  class = NULL,
                  style = "text-align:center;"
                )
              ),
              tabPanel(
                # ATTENTION: If you change the title, you also have to change
                # the
                # corresponding part above for the "source == source" button
                # reaction. Otherwise the tabs won't hide/show up anymore.
                # >> ATTENTION <<
                title = "PostgreSQL",
                # >> ATTENTION << for title. See above.
                id = ns("source_tab_pg"),
                h4("Source Database Connection"),
                box(
                  title = "Preloadings",
                  # background = "blue",
                  #solidHeader = TRUE,
                  width = 12,
                  selectInput(
                    # This will be filled in the server part.
                    inputId = ns("source_pg_presettings_list"),
                    label = NULL,
                    choices = NULL,
                    selected = NULL
                  ),
                  style = "text-align:center;"
                ),
                textInput(
                  inputId = ns("config_sourcedb_dbname"),
                  label = "DB Name",
                  placeholder = "Enter the name of the database ..."
                ),
                textInput(
                  inputId = ns("config_sourcedb_host"),
                  label = "IP",
                  placeholder = "Enter the IP here in format '192.168.1.1' ..."
                ),
                textInput(
                  inputId = ns("config_sourcedb_port"),
                  label = "Port",
                  placeholder = "Enter the Port of the database connection ..."
                ),
                textInput(
                  inputId = ns("config_sourcedb_user"),
                  label = "Username",
                  placeholder =
                    "Enter the Username for the database connection ..."
                ),
                passwordInput(
                  inputId = ns("config_sourcedb_password"),
                  label = "Password",
                  placeholder = "Enter the database password ..."
                ),
                br(),
                actionButton(
                  inputId = ns("source_pg_test_connection"),
                  label = "Test & Save connection",
                  icon = icon("database"),
                  style = "text-align:center;"
                )
              )
            )
          ),
          box(
            title =  "TARGET settings",
            width = 6,
            #solidHeader = TRUE,
            tabBox(
              # The id lets us use input$target_tabs
              # on the server to find the current tab
              id = ns("target_tabs"),
              width = 12,
              # selected = "PostgreSQL",
              tabPanel(
                # ATTENTION: If you change the title, you also have to change
                # the
                # corresponding part above for the "target == source" button
                # reaction. Otherwise the tabs won't hide/show up anymore.
                # >> ATTENTION <<
                title = "CSV",
                # >> ATTENTION << for title. See above.
                id = ns("target_tab_csv"),
                h4("Target CSV Upload"),
                box(
                  title = "Available CSV-Systems",
                  # background = "blue",
                  # solidHeader = TRUE,
                  width = 12,
                  selectInput(
                    # This will be filled in the server part.
                    inputId = ns("target_csv_presettings_list"),
                    label = NULL,
                    choices = NULL,
                    selected = NULL
                  ),
                  style = "text-align:center;"
                ),
                div(
                  paste(
                    "Please choose the directory of your",
                    "\u00A7",
                    "21 target data in csv format (default: '/home/input')."
                  )
                ),
                br(),
                # If the path is already set, display it
                conditionalPanel(
                  condition = paste0(
                    "typeof ",
                    "output['moduleConfig-target_csv_dir']",
                    " !== 'undefined'"
                  ),
                  verbatimTextOutput(ns("target_csv_dir")),
                  style = "text-align:center;"
                ),
                br(),

                # If there is no path set yet: Display the button to choose it
                shinyFiles::shinyDirButton(
                  id = ns("config_targetdir_in"),
                  label = "Target Dir",
                  title = "Please select the target directory",
                  buttonType = "default",
                  icon = icon("folder"),
                  class = NULL,
                  style = "text-align:center;"
                )
              ),
              tabPanel(
                # ATTENTION: If you change the title, you also have to change
                # the
                # corresponding part above for the "target == source" button
                # reaction. Otherwise the tabs won't hide/show up anymore.
                # >> ATTENTION <<
                title = "PostgreSQL",
                # >> ATTENTION << for title. See above.
                id = ns("target_tab_pg"),
                h4("Target Database Connection"),
                box(
                  title = "Preloadings",
                  # background = "blue",
                  #solidHeader = TRUE,
                  width = 12,
                  selectInput(
                    # This will be filled in the server part.
                    inputId = ns("target_pg_presettings_list"),
                    label = NULL,
                    choices = NULL,
                    selected = NULL
                  ),
                  style = "text-align:center;"
                ),
                textInput(
                  inputId = ns("config_targetdb_dbname"),
                  label = "DB Name",
                  placeholder = "Enter the name of the database ..."
                ),
                textInput(
                  inputId = ns("config_targetdb_host"),
                  label = "IP",
                  placeholder = "Enter the IP here in format '192.168.1.1' ..."
                ),
                textInput(
                  inputId = ns("config_targetdb_port"),
                  label = "Port",
                  placeholder = "Enter the Port of the database connection ..."
                ),
                textInput(
                  inputId = ns("config_targetdb_user"),
                  label = "Username",
                  placeholder =
                    "Enter the Username for the database connection ..."
                ),
                passwordInput(
                  inputId = ns("config_targetdb_password"),
                  label = "Password",
                  placeholder = "Enter the database password ..."
                ),
                br(),
                actionButton(
                  inputId = ns("target_pg_test_connection"),
                  label = "Test & Save connection",
                  icon = icon("database"),
                  style = "text-align:center;"
                )
              )
            )
          )
        )
      ),
      column(
        3,
        conditionalPanel(
          condition =
            "typeof output['moduleConfig-mdr_present'] == 'undefined'",
          box(
            title = "Load Metadata Repository",
            actionButton(
              inputId = ns("config_load_mdr"),
              label = "Load MDR",
              icon = icon("table")
            ),
            width = 12
          )
        ),
        conditionalPanel(
          condition =
            "typeof output['moduleConfig-mdr_present'] != 'undefined'",
          box(
            title = "Load the data",
            #solidHeader = T,
            h4(textOutput(ns("source_system_feedback_txt"))),
            br(),
            h4(textOutput(ns("target_system_feedback_txt"))),
            br(),
            conditionalPanel(
              condition = paste0(
                "typeof output",
                "['moduleConfig-source_system_feedback_txt'] != ",
                "'undefined'"),
              actionButton(ns("dash_load_btn"),
                           "Load data",
                           icon = icon("file-upload"))
            ),
            width = 12,
          ),
          box(
            title = "Analyse only the source system",
            actionButton(
              inputId = ns("target_system_to_source_system_btn"),
              icon = icon("cogs"),
              label = " Set TARGET = SOURCE",
              style = paste0(
                "white-space: normal; ",
                "text-align:center; ",
                "padding: 9.5px 9.5px 9.5px 9.5px; ",
                "margin: 6px 10px 6px 10px;")
            ),
            width = 12
          )
        )
      )
    )
  )
}
