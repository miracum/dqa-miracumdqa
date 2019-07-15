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

shinyUI(dashboardPage(skin = "black",
                      
                      # Application title
                      dashboardHeader(title = "MIRACUM DQA Tool"),
                      
                      dashboardSidebar(
                        
                        # Include shinyjs in the UI Sidebar
                        shinyjs::useShinyjs(), 
                        shinyjs::extendShinyjs(script = "./_utilities/reset.js", functions = "reset"), # Add the js code to the page
                        
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
                        shinyjs::extendShinyjs(script = "./_utilities/reset.js", functions = "reset"), # Add the js code to the page
                        
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
                          
                          tabItem(tabName = "tab_descriptive",
                                  moduleDescriptiveUI("moduleDescriptive")
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
