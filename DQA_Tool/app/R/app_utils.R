# (c) 2019 Lorenz Kapsner
# function to run on startup
onStart <- function(session, rv, input, output){
  if (file.exists("./_settings/global_settings.JSON")){
    cat("\nglobal_settings.JSON present\n")
    user_settings <- fromJSON("./_settings/global_settings.JSON")
    
    cat("\nUpdate radio button:", user_settings[["db"]], "\n")
    updateRadioButtons(session, "moduleConfig-config_targetdb_rad", selected = user_settings[["db"]])
    
    cat("\nUpdate source file path:", user_settings[["source_path"]], "\n")
    rv$sourcefiledir <- user_settings[["source_path"]]
    shinyDirChoose(input, "moduleConfig-config_sourcedir_in", updateFreq = 0, session = session, defaultPath = user_settings[["source_path"]], roots = c(home="/home/"), defaultRoot = "home")
    
    cat("\nUpdate site name:", user_settings[["site_name"]], "\n")
    rv$sitename <- user_settings[["site_name"]]
    updateSelectInput(session, "moduleConfig-config_sitename", selected = user_settings[["site_name"]])
    
    rv[["user_settings"]] <- user_settings
  } 
}

# create summary tables
summaryTable <- function(){
  return(data.table("variable" = character(), 
                    "distinct" = integer(), 
                    "valids" = integer(),
                    "missings" = integer()))
}

# render quick ETL check tables
renderQuickETL <- function(dat_table){
  DT::datatable(dat_table, options=list(dom = "t", scrollY="30vh", pageLength = nrow(dat_table)), rownames = F) %>% 
    formatStyle(columns=2,
                backgroundColor = styleEqual(c("passed", "failed"), c("lightgreen", "red"))) %>%
    formatStyle(columns=3,
                backgroundColor = styleEqual(c("passed", "failed"), c("lightgreen", "red")))
}

