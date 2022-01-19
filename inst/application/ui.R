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

shiny::shinyUI(
  shiny::tagList(
    shinydashboard::dashboardPage(
      skin = "black",

      # Application title
      shinydashboard::dashboardHeader(title = "MIRACUM DQA Tool"),

      shinydashboard::dashboardSidebar(

        # Include shinyjs in the UI Sidebar
        shinyjs::useShinyjs(),

        #Sidebar Panel
        shinydashboard::sidebarMenu(
          id = "tabs",
          shinydashboard::menuItem(
            text = "Dashboard",
            tabName = "tab_dashboard",
            icon = icon("tachometer-alt")
          ),
          shinydashboard::sidebarMenuOutput("menu"),
          shinydashboard::menuItem(
            text = "Config",
            tabName = "tab_config",
            icon = icon("cogs")
          ),
          shinydashboard::sidebarMenuOutput("mdr"),
          shinydashboard::menuItem(
            text = "Logfile",
            tabName = "tab_log",
            icon = icon("terminal")
          ),
          shiny::tags$hr(),
          shiny::actionButton(
            inputId = "reset",
            label = "Reset DQA Tool"
          )
        ),
        shiny::div(
          class = "sidebar-menu",
          style = paste0("position:fixed; bottom:0; left:0; ",
                         "white-space: normal; text-align:left; ",
                         "padding: 9.5px 9.5px 9.5px 9.5px; ",
                         "margin: 6px 10px 6px 10px; ",
                         "box-sizing:border-box; heigth: auto; width: 230px;"),
          shiny::HTML(
            paste0(
              "Version:",
              "<br/>R: ", paste(
                R.Version()[c("major", "minor")], collapse = "."),
              "<br/>DIZutils: ", utils::packageVersion("DIZutils"),
              "<br/>DQAstats: ", utils::packageVersion("DQAstats"),
              "<br/>DQAgui: ", utils::packageVersion("DQAgui"),
              "<br/>miRacumDQA: ", utils::packageVersion("miRacumDQA"),
              "<br/><br/>\u00A9 Universitätsklinikum Erlangen<br/>"
            )
          )
        )
      ),

      shinydashboard::dashboardBody(

        # Include shinyjs in the UI Body
        shinyjs::useShinyjs(),

        shinydashboard::tabItems(
          shinydashboard::tabItem(
            tabName = "tab_dashboard",
            DQAgui::module_dashboard_ui("moduleDashboard")
          ),

          shinydashboard::tabItem(
            tabName = "tab_config",
            DQAgui::module_config_ui("moduleConfig")
          ),

          shinydashboard::tabItem(
            tabName = "tab_descriptive",
            DQAgui::module_descriptive_ui("moduleDescriptive")
          ),

          shinydashboard::tabItem(
            tabName = "tab_atemp_plausibility",
            DQAgui::module_atemp_pl_ui("moduleAtempPlausibility")
          ),

          shinydashboard::tabItem(
            tabName = "tab_uniq_plausibility",
            DQAgui::module_uniq_plaus_ui("moduleUniquePlausibility")
          ),

          shinydashboard::tabItem(
            tabName = "tab_completeness",
            DQAgui::module_completeness_ui("moduleCompleteness")
          ),

          #% shinydashboard::tabItem(
          #%   tabName = "tab_visualizations",
          #%   module_visualizations_ui("moduleVisulizations")
          #% ),

          shinydashboard::tabItem(
            tabName = "tab_report",
            DQAgui::module_report_ui("moduleReport")
          ),

          shinydashboard::tabItem(
            tabName = "tab_mdr",
            DQAgui::module_mdr_ui("moduleMDR")
          ),

          shinydashboard::tabItem(
            tabName = "tab_log",
            DQAgui::module_log_ui("moduleLog")
          )
        )
      )
    )
  )
)
