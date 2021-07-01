file <-
  "~/git-local/miracum/miracumdqa/inst/application/_utilities/MDR/mdr.csv"
file_output <- paste0("~/git-local/miracum/miracumdqa/",
                      "inst/application/_utilities/MDR/mdr_cleanup.csv")
mdr <- data.table::fread(file = file, stringsAsFactors = FALSE)

## Remove double-quotation marks: --> "" <--
mdr <-
  mdr[, lapply(.SD, function(x) {
    gsub('""', '"', x, fixed = TRUE)
  })]


## Do your stuff here


data.table::fwrite(x = mdr, file = file_output, sep = ";")
