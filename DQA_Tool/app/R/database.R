# by Lorenz Kapsner
# get db_settings
getDBsettings <- function(input){
  # create description of column selections
  vec <- c("dbname", "host", "port", "user", "password")
  
  tab <- lapply(vec, function(g) {
    data.table("keys" = g, "value" = eval(parse(text=paste0("input[['moduleConfig-config_targetdb_", g, "']]"))))
  })
  
  tab <- do.call(rbind, tab)
  
  # if one column is selected multiple times
  if ("" %in% tab[,value] || any(tab[,grepl("\\s", value)])){
    showModal(modalDialog(
      title = "Invalid values",
      "No empty strings or spaces allowed in database configurations."
    ))
    return(NULL)
    
  } else {
    print(tab)
    outlist <- lapply(setNames(vec, vec), function(g){
      tab[keys==g,value]
    })
    return(outlist)
  }
}

# test db connection
testDBcon <- function(db_settings){
  drv <- RPostgres::Postgres()
  tryCatch({
    db_con <- dbConnect(
      drv = drv,
      dbname = db_settings$dbname,
      host = db_settings$host,
      port = db_settings$port,
      user = db_settings$user,
      password = db_settings$password
    )
    return(db_con)
  }, error = function(e){
    showModal(modalDialog(
      title = "Error occured during testing database connection",
      "An error occured during the test of the database connection. Please check your settings and try again."
    ))
    cat("\nDB connection error\n")
    return(NULL)
  })
}
