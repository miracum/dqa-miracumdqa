# (c) 2019 Lorenz Kapsner
shinyUI(dashboardPage(skin = "black",
                      
                      # Application title
                      dashboardHeader(title = "MIRACUM DQA"),
                      
                      dashboardSidebar(
                        
                        # Include shinyjs in the UI Sidebar
                        shinyjs::useShinyjs(), 
                        extendShinyjs(script = "./_utilities/reset.js", functions = "reset"), # Add the js code to the page
                        
                        #Sidebar Panel
                        sidebarMenu(id = "tabs",
                                    menuItem("Dashboard", tabName = "tab_dashboard", icon = icon("tachometer-alt")),
                                    sidebarMenuOutput("menu"),
                                    menuItem("Settings", tabName = "tab_config", icon = icon("cogs")),
                                    menuItem("DQ MDR", tabName = "tab_mdr", icon = icon("database")),
                                    tags$hr(),
                                    actionButton("reset", "Reset DQA Tool")
                        )),
                      
                      dashboardBody(
                        
                        # Include shinyjs in the UI Body
                        shinyjs::useShinyjs(),
                        
                        # js reset function 
                        # https://stackoverflow.com/questions/25062422/restart-shiny-session
                        extendShinyjs(script = "./_utilities/reset.js", functions = "reset"), # Add the js code to the page
                        
                        tabItems(
                          tabItem(tabName = "tab_dashboard",
                                  moduleDashboardUI("moduleDashboard")
                          ),
                          
                          tabItem(tabName = "tab_config",
                                  moduleConfigUI("moduleConfig")
                          ), 
                          
                          tabItem(tabName = "tab_rawdata1",
                                  moduleRawdata1UI("moduleRawdata1")
                          ), 
                          
                          tabItem(tabName = "tab_numerical",
                                  moduleNumericalUI("moduleNumerical")
                          ), 
                          
                          tabItem(tabName = "tab_categorical",
                                  moduleCategoricalUI("moduleCategorical")
                          ),
                          
                          tabItem(tabName = "tab_plausibility",
                                  modulePlausibilityUI("modulePlausibility")
                          ),
                          
                          tabItem(tabName = "tab_visualizations",
                                  moduleVisualizationsUI("moduleVisulizations")
                          ), 
                          
                          tabItem(tabName = "tab_report",
                                  moduleReportUI("moduleReport")
                          ),
                          
                          tabItem(tabName = "tab_mdr",
                                  moduleMDRUI("moduleMDR")
                          )
                          
                        )
                      )
))
