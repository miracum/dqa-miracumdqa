# by Lorenz Kapsner
# fire SQL to database
fireSQL <- function(rv, jsonobj){
  withProgress(
    message = paste0("Getting ", jsonobj, " data from server"), value = 0, {
      # avoid sql-injection
      # https://db.rstudio.com/best-practices/run-queries-safely/
      sql <- DBI::sqlInterpolate(rv$db_con, rv$sql[[jsonobj]])
      incProgress(1/1, detail = "... working hard to get data ...")
      # get data
      rv$data_objects[[jsonobj]] <- jsonobj
      return(data.table(dbGetQuery(rv$db_con, sql), stringsAsFactors = TRUE))
    })
}

# load csv files
loadCSV <- function(rv, filename){
  withProgress(
    message = paste0("Reading ", filename, " file from directory"), value = 0, {
      incProgress(1/1, detail = "...name working hard to read data ...")
      # get data
      rv$data_objects[[filename]] <- filename
      cat("\nFile path:", paste0(rv$sourcefiledir, "/", filename))
      return(fread(paste0(rv$sourcefiledir, "/", filename), header = T))
    })
}
