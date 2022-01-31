# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2022 Universitätsklinikum Erlangen
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

## ##############
## Converts the exportet json from influx to textfile
## ##############

# Cleanup the backend in RStudio:
cat("\014") # Clears the console (imitates CTR + L)
rm(list = ls()) # Clears the Global Environment/variables/data
invisible(gc()) # Garbage collector/Clear unused RAM


## ##############
## Change file and dir for input and output here:
## ##############
# --> Input:
influx_dir <- "~/share/influx_data/"
influx_filename <- "response_2020-03-13-0933.json"

# --> Output:
output_dir <- influx_dir
output_filename <- "output.txt"


## ##############
## Here starts the program
## ##############
#%install.packages("rjson")
library("rjson")

output_file <- paste0(output_dir, output_filename)

# Delete old file
unlink(output_file)

# Create new file:
output_file_con <- file(output_file, open = "a")

# Read json file
json <- fromJSON(file = paste0(influx_dir, influx_filename))


escape_space <- function(string) {
  return(gsub(" ", "\\\ ", string, fixed = TRUE))
}

# Get position of necessary keys from json:
keys <- json[["results"]][[1]][["series"]][[1]][["columns"]]
key_pos_item <-  match("item", keys)
key_pos_lay_term <- match("lay_term", keys)
key_pos_n <- match("n", keys)
key_pos_site <- match("site", keys)
key_pos_system <- match("system", keys)

print("Starting to export json data to txt ...")

values <- json[["results"]][[1]][["series"]][[1]][["values"]]
print(paste0("Input has ", length(values), " entries."))

i <- 0
for (value in values) {
  i <- i + 1
  new_line <- paste0(
    ifelse(i == 1, "", "\n"),
    "item_counts,site=",
    escape_space(value[[key_pos_site]]),
    ",lay_term=",
    escape_space(value[[key_pos_lay_term]]),
    ",item=",
    escape_space(value[[key_pos_item]]),
    ",system=",
    escape_space(value[[key_pos_system]]),
    " n=",
    value[[key_pos_n]]
  )

  # write new line to the file
  #%print(new_line)
  cat(new_line, file = output_file_con)
}
print(paste0("Finished. Wrote ", i, " entries to ", output_file))
close(output_file_con)
