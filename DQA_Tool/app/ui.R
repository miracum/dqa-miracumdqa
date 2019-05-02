shinyUI(dashboardPage(skin = "black",
                      
                      # Application title
                      dashboardHeader(title = "MIRACUM DQA Tool"),
                      
                      dashboardSidebar(
                          
                          # Include shinyjs in the UI Sidebar
                          shinyjs::useShinyjs(), 
                          extendShinyjs(script = "reset.js", functions = "reset"), # Add the js code to the page
                          
                          #Sidebar Panel
                          sidebarMenu(id = "tabs",
                                      menuItem("Dashboard", tabName = "tab_dashboard", icon = icon("tachometer-alt")),
                                      sidebarMenuOutput("menu"),
                                      menuItem("Settings", tabName = "tab_config", icon = icon("cogs")),
                                      menuItem("DQ MDR", tabName = "tab_mdr", icon = icon("database")),
                                      actionButton("reset", "Reset DQA Tool")
                          )),
                      
                      dashboardBody(
                          
                          # Include shinyjs in the UI Body
                          shinyjs::useShinyjs(),
                          
                          # js reset function 
                          # https://stackoverflow.com/questions/25062422/restart-shiny-session
                          extendShinyjs(script = "reset.js", functions = "reset"), # Add the js code to the page
                          
                          tabItems(
                              tabItem(tabName = "tab_dashboard",
                                      fluidRow(
                                          column(6,
                                                 box(title = "Welcome to your MIRACUM Data-Quality-Analysis dashboard",
                                                     verbatimTextOutput("dash_instruction"),
                                                     conditionalPanel(
                                                         condition = "output.dbConnection",
                                                         actionButton("dash_load_btn", "Load data")
                                                     ),
                                                     width = 12
                                                 )
                                          ),
                                          column(6,
                                                 conditionalPanel(
                                                     condition = "output.dbConnection",
                                                     box(title = "Target system overview",
                                                         tableOutput("dash_summary_target"),
                                                         width = 12
                                                     )
                                                 ),
                                                 conditionalPanel(
                                                     condition = "output.config_sourcedir_out != ''",
                                                     box(title = "Source system overview",
                                                         tableOutput("dash_summary_source"),
                                                         width = 12
                                                     )
                                                 )
                                          ) 
                                      )
                              ),
                              
                              tabItem(tabName = "tab_config",
                                      fluidRow(
                                          column(6,
                                                 box(
                                                     title = "Target Database Configuration",
                                                     radioButtons(inputId = "config_targetdb_rad", 
                                                                  label = "Pleas select the target database",
                                                                  choices = list("i2b2" = "i2b2", 
                                                                                 "OMOP" = "omop"), 
                                                                  selected = NULL, 
                                                                  inline = TRUE),
                                                     textInput("config_targetdb_dbname", label = "Database name"),
                                                     textInput("config_targetdb_hostname", label = "Host name"),
                                                     textInput("config_targetdb_port", label = "Port"),
                                                     textInput("config_targetdb_user", label = "Username"),
                                                     passwordInput("config_targetdb_password", label = "Password"),
                                                     div(class = "row", style = "text-align: center;",
                                                         actionButton("config_targetdb_save_btn", "Save settings"),
                                                         actionButton("config_targetdb_test_btn", "Test connection")),
                                                     width = 12
                                                 )),
                                          column(6,
                                                 
                                                 box(title = "Sitename",
                                                     div(class = "row",
                                                         div(class = "col-sm-8", textInput("config_sitename", "Please enter the name of your site")),
                                                         div(class = "col-sm-4")
                                                     ),
                                                     width = 12
                                                 ),
                                                 box(title = "Source File Directory",
                                                     h5(tags$b("Please choose the directory of your §21 source data in csv format")),
                                                     div(class = "row",
                                                         div(class="col-sm-3", shinyDirButton("config_sourcedir_in", 
                                                                                              "Source Dir", 
                                                                                              "Please select the source file directory", 
                                                                                              buttonType = "default", 
                                                                                              class = NULL, 
                                                                                              icon = NULL, 
                                                                                              style = NULL)),
                                                         div(class = "col-sm-9", verbatimTextOutput("config_sourcedir_out"))
                                                     ),
                                                     width = 12
                                                 )
                                          )
                                      )
                              ), 
                              
                              tabItem(tabName = "tab_rawdata1",
                                      fluidRow(
                                          box(title = "Select data",
                                              uiOutput("rawdata1_uiout"),
                                              width = 4
                                          ),
                                          box(
                                              title = "Review raw data",
                                              dataTableOutput("rawdata1_table"),
                                              width = 8
                                          )
                                      )
                              ),
                              
                              tabItem(tabName = "tab_mdr",
                                      box(
                                        title = "DQ Metadatarepository",
                                        dataTableOutput("mdr_table"),
                                        width = 12
                                      ))
                          )
                      )
))
