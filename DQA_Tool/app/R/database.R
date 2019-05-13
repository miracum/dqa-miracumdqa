# by Lorenz Kapsner
# get db_settings
getDBsettings <- function(input, rv){
  # create description of column selections
  vec <- c("dbname", "host", "port", "user", "password")
  
  tab <- lapply(vec, function(g) {
    data.table("keys" = g, "value" = eval(parse(text=paste0("input[['moduleConfig-config_targetdb_", g, "']]"))))
  })
  
  rv$tab <- do.call(rbind, tab)
  
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
