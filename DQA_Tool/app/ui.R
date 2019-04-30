shinyUI(dashboardPage(skin = "black",

    # Application title
    dashboardHeader(title = "Shiny DQA Tool"),

    dashboardSidebar(

        # Include shinyjs in the UI Sidebar
        shinyjs::useShinyjs(), 
        
        #Sidebar Panel
        sidebarMenu(id = "tabs",
                    menuItem("Dashboard", tabName = "tab_dashboard", icon = icon("file")),
                    sidebarMenuOutput("menu"),
                    menuItem("Settings", tabName = "tab_config", icon = icon("file"))
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
                        box(title = "Overview",
                            verbatimTextOutput("dash_instruction"),
                            conditionalPanel(
                                condition = "output.dbConnection",
                                actionButton("dash_load_btn", "Load data")
                            ),
                            width = 6
                        )
                    )
            ),
            
            tabItem(tabName = "tab_config",
                    fluidRow(
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
                            textInput("config_targetdb_password", label = "Password"),
                            div(class = "row", style = "text-align: center;",
                                actionButton("config_targetdb_save_btn", "Save settings"),
                                actionButton("config_targetdb_test_btn", "Test connection")),
                            width = 6
                        ),
                        
                        box(title = "Source File Directory",
                            div(class = "row",
                                div(class="col-sm-4", shinyDirButton("config_sourcedir_in", 
                                                                     "Source Dir", 
                                                                     "Please select the source file directory", 
                                                                     buttonType = "default", 
                                                                     class = NULL, 
                                                                     icon = NULL, 
                                                                     style = NULL)),
                                div(class = "col-sm-8", verbatimTextOutput("config_sourcedir_out"))
                            ),
                            width = 6
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
                            title = "Raw data",
                            dataTableOutput("rawdata1_table"),
                            width = 8
                        )
                    )
            )
        )
    )
))
