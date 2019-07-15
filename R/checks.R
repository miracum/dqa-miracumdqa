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

# quick checks
quickETLChecks <- function(results){

  # get names
  obj_names <- names(results[["description"]])

  # initialize output table
  out <- data.table::data.table("Variable" = character(0),
                    "Check Distincts" = character(0),
                    "Check Valids" = character(0))


  for (i in obj_names){
    check_distinct <- ifelse(results[["counts"]][[i]]$source_data$cnt$distinct == results[["counts"]][[i]]$target_data$cnt$distinct,
                             "passed", "failed")
    check_valids <- ifelse(results[["counts"]][[i]]$source_data$cnt$valids == results[["counts"]][[i]]$target_data$cnt$valids,
                           "passed", "failed")
    out <- rbind(out, data.table::data.table("Variable" = i,
                                 "Check Distincts" = check_distinct,
                                 "Check Valids" = check_valids))
  }
  return(out)
}
