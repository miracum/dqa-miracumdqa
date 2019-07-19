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

shiny::shinyUI(shinydashboard::dashboardPage(skin = "black",

                      # Application title
                      shinydashboard::dashboardHeader(title = "MIRACUM DQA Tool"),

                      shinydashboard::dashboardSidebar(

                        # Include shinyjs in the UI Sidebar
                        shinyjs::useShinyjs(),
                        shinyjs::extendShinyjs(script = "./_utilities/reset.js", functions = "reset"), # Add the js code to the page

                        #Sidebar Panel
                        shinydashboard::sidebarMenu(id = "tabs",
                                                    shinydashboard::menuItem("Dashboard", tabName = "tab_dashboard", icon = icon("tachometer-alt")),
                                                    shinydashboard::sidebarMenuOutput("menu"),
                                                    shinydashboard::menuItem("Settings", tabName = "tab_config", icon = icon("cogs")),
                                                    shinydashboard::menuItem("DQ MDR", tabName = "tab_mdr", icon = icon("database")),
                                    shiny::tags$hr(),
                                    shiny::actionButton("reset", "Reset DQA Tool")
                        )),

                      shinydashboard::dashboardBody(

                        # Include shinyjs in the UI Body
                        shinyjs::useShinyjs(),

                        # js reset function
                        # https://stackoverflow.com/questions/25062422/restart-shiny-session
                        shinyjs::extendShinyjs(script = "./_utilities/reset.js", functions = "reset"), # Add the js code to the page

                        shinydashboard::tabItems(
                          shinydashboard::tabItem(tabName = "tab_dashboard",
                                  moduleDashboardUI("moduleDashboard")
                          ),

                          shinydashboard::tabItem(tabName = "tab_config",
                                  moduleConfigUI("moduleConfig")
                          ),

                          shinydashboard::tabItem(tabName = "tab_rawdata1",
                                  moduleRawdata1UI("moduleRawdata1")
                          ),

                          shinydashboard::tabItem(tabName = "tab_descriptive",
                                  moduleDescriptiveUI("moduleDescriptive")
                          ),

                          shinydashboard::tabItem(tabName = "tab_atemp_plausibility",
                                  moduleAtempPlausibilityUI("moduleAtempPlausibility")
                          ),

                          shinydashboard::tabItem(tabName = "tab_unique_plausibility",
                                  moduleUniquePlausibilityUI("moduleUniquePlausibility")
                          ),

                          shinydashboard::tabItem(tabName = "tab_visualizations",
                                  moduleVisualizationsUI("moduleVisulizations")
                          ),

                          shinydashboard::tabItem(tabName = "tab_report",
                                  moduleReportUI("moduleReport")
                          ),

                          shinydashboard::tabItem(tabName = "tab_mdr",
                                  moduleMDRUI("moduleMDR")
                          )

                        )
                      )
))
