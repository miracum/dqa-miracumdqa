# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019 Universitätsklinikum Erlangen
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

shiny::shinyUI(shiny::tagList(shinydashboard::dashboardPage(skin = "black",

                                                            # Application title
                                                            shinydashboard::dashboardHeader(title = "MIRACUM DQA Tool"),

                                                            shinydashboard::dashboardSidebar(

                                                              # Include shinyjs in the UI Sidebar
                                                              shinyjs::useShinyjs(),

                                                              # js reset function
                                                              # https://stackoverflow.com/questions/25062422/restart-shiny-session
                                                              shinyjs::extendShinyjs(script = system.file("application/reset.js", package = "DQAgui"), functions = "reset"), # Add the js code to the page

                                                              #Sidebar Panel
                                                              shinydashboard::sidebarMenu(id = "tabs",
                                                                                          shinydashboard::menuItem("Dashboard", tabName = "tab_dashboard", icon = icon("tachometer-alt")),
                                                                                          shinydashboard::sidebarMenuOutput("menu"),
                                                                                          shinydashboard::menuItem("Config", tabName = "tab_config", icon = icon("cogs")),
                                                                                          shinydashboard::sidebarMenuOutput("mdr"),
                                                                                          shiny::tags$hr(),
                                                                                          shiny::actionButton("reset", "Reset DQA Tool")
                                                              ),
                                                              shiny::div(class = "sidebar-menu", style = "position:fixed; bottom:0; left:0; white-space: normal; text-align:left;
                                                                              padding: 9.5px 9.5px 9.5px 9.5px; margin: 6px 10px 6px 10px; box-sizing:border-box; heigth: auto; width: 230px;",
                                                                         shiny::HTML("\u00A9 Universitätsklinikum Erlangen<br/><i>programmed by Lorenz A. Kapsner</i>"))
                                                            ),

                                                            shinydashboard::dashboardBody(

                                                              # Include shinyjs in the UI Body
                                                              shinyjs::useShinyjs(),

                                                              shinydashboard::tabItems(
                                                                shinydashboard::tabItem(tabName = "tab_dashboard",
                                                                                        DQAgui::moduleDashboardUI("moduleDashboard")
                                                                ),

                                                                shinydashboard::tabItem(tabName = "tab_config",
                                                                                        DQAgui::moduleConfigUI("moduleConfig")
                                                                ),

                                                                shinydashboard::tabItem(tabName = "tab_descriptive",
                                                                                        DQAgui::moduleDescriptiveUI("moduleDescriptive")
                                                                ),

                                                                shinydashboard::tabItem(tabName = "tab_atemp_plausibility",
                                                                                        DQAgui::moduleAtempPlausibilityUI("moduleAtempPlausibility")
                                                                ),

                                                                shinydashboard::tabItem(tabName = "tab_unique_plausibility",
                                                                                        DQAgui::moduleUniquePlausibilityUI("moduleUniquePlausibility")
                                                                ),

                                                                shinydashboard::tabItem(tabName = "tab_visualizations",
                                                                                        DQAgui::moduleVisualizationsUI("moduleVisulizations")
                                                                ),

                                                                shinydashboard::tabItem(tabName = "tab_report",
                                                                                        DQAgui::moduleReportUI("moduleReport")
                                                                ),

                                                                shinydashboard::tabItem(tabName = "tab_mdr",
                                                                                        DQAgui::moduleMDRUI("moduleMDR")
                                                                )

                                                              )
                                                            )
)))
