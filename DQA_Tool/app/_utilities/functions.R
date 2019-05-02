# get db_settings
getDBsettings <- function(input, rv){
  rv$tab <- data.table("keys" = character(), "value" = character())
  # create description of column selections
  vec <- c("dbname", "host", "port", "user", "password")
  selections <- c("config_targetdb_dbname", "config_targetdb_hostname", "config_targetdb_port", "config_targetdb_user", "config_targetdb_password")
  
  lapply(1:length(vec), function(g) {
    rv$tab <- rbind(rv$tab, cbind("keys" = vec[g], "value" = eval(parse(text=paste0("input$", selections[g])))))
  })
  
  # if one column is selected multiple times
  if ("" %in% rv$tab[,value] || any(rv$tab[,grepl("\\s", value)])){
    showModal(modalDialog(
      title = "Invalid values",
      "No empty strings or spaces allowed in database configurations."
    ))
    return(NULL)
    
  } else {
    print(rv$tab)
    outlist <- lapply(setNames(vec, vec), function(g){
      rv$tab[keys==g,value]
    })
    return(outlist)
  }
}

# test db connection
testDBcon <- function(rv){
  drv <- RPostgres::Postgres()
  tryCatch({
    rv$db_con <- dbConnect(
      drv = drv,
      dbname = rv$db_settings$dbname,
      host = rv$db_settings$host,
      port = rv$db_settings$port,
      user = rv$db_settings$user,
      password = rv$db_settings$password
    )
  }, error = function(e){
    showModal(modalDialog(
      title = "Error occured during testing database connection",
      "An error occured during the test of the database connection. Please check your settings and try again."
    ))
    rv$db_con <- NULL
    cat("\nDB connection error\n")
  })
}

# fire SQL to database
fireSQL <- function(rv, jsonobj){
  withProgress(
    message = paste0("Getting ", jsonobj, " data from server"), value = 0, {
    # avoid sql-injection
    # https://db.rstudio.com/best-practices/run-queries-safely/
    sql <- DBI::sqlInterpolate(rv$db_con, rv$sql[[jsonobj]])
    incProgress(1/1, detail = "... working hard to get data ...")
    # get data
    rv$data_objects[[jsonobj]] <- paste0("rv$", jsonobj)
    return(data.table(dbGetQuery(rv$db_con, sql), stringsAsFactors = TRUE))
  })
}

# load csv files
loadCSV <- function(rv, file){
  withProgress(
    message = paste0("Reading ", file, " file from directory"), value = 0, {
      incProgress(1/1, detail = "... working hard to read data ...")
      # get data
      rv$data_objects[[file]] <- paste0("rv$", file)
      cat("\nFile path:", paste0(rv$sourcefiledir, "/", file))
      return(fread(paste0(rv$sourcefiledir, "/", file), header = T))
    })
}

# function to run on startup
onStart <- function(session, rv, input, output){
  if (file.exists("./_settings/global_settings.JSON")){
    cat("\nglobal_settings.JSON present\n")
    user_settings <- fromJSON("./_settings/global_settings.JSON")
    
    cat("\nUpdate radio button:", user_settings[["db"]], "\n")
    updateRadioButtons(session, "config_targetdb_rad", selected = user_settings[["db"]])
    
    cat("\nUpdate source file path:", user_settings[["source_path"]], "\n")
    rv$sourcefiledir <- user_settings[["source_path"]]
    shinyDirChoose(input, "config_sourcedir_in", updateFreq = 0, session = session, defaultPath = user_settings[["source_path"]], roots = c(home="/home/"), defaultRoot = "home")
    
    cat("\nUpdate site name:", user_settings[["site_name"]], "\n")
    rv$sitename <- user_settings[["site_name"]]
    updateTextInput(session, "config_sitename", value = user_settings[["site_name"]])
    
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