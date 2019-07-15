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

# get db_settings
getDBsettings <- function(input){
  # create description of column selections
  vec <- c("dbname", "host", "port", "user", "password")

  tab <- lapply(vec, function(g) {
    data.table::data.table("keys" = g, "value" = eval(parse(text=paste0("input[['moduleConfig-config_targetdb_", g, "']]"))))
  })

  tab <- do.call(rbind, tab)

  # if one column is selected multiple times
  if ("" %in% tab[,get("value")] || any(tab[,grepl("\\s", get("value"))])){
    shiny::showModal(modalDialog(
      title = "Invalid values",
      "No empty strings or spaces allowed in database configurations."
    ))
    return(NULL)

  } else {
    print(tab)
    outlist <- lapply(stats::setNames(vec, vec), function(g){
      tab[get("keys")==g,get("value")]
    })
    return(outlist)
  }
}

# test db connection
testDBcon <- function(db_settings, headless = FALSE){
  drv <- RPostgres::Postgres()
  tryCatch({
    db_con <- RPostgres::dbConnect(
      drv = drv,
      dbname = db_settings$dbname,
      host = db_settings$host,
      port = db_settings$port,
      user = db_settings$user,
      password = db_settings$password
    )
    return(db_con)
  }, error = function(e){
    if (isFALSE(headless)){
      shiny::showModal(modalDialog(
        title = "Error occured during testing database connection",
        "An error occured during the test of the database connection. Please check your settings and try again."
      ))
    }
    cat("\nDB connection error\n")
    return(NULL)
  })
}
