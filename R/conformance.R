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

valueConformance <- function(results){
  # get names
  obj_names <- names(results[["description"]])

  # initialize final list to output
  outlist <- list()

  # loop over objects
  for (i in obj_names){
    desc_out <- results$description[[i]]
    count_out <- results$counts[[i]]
    stat_out <- results$statistics[[i]]

    for (j in c("source_data", "target_data")){
      d_out <- desc_out[[j]]
      s_out <- stat_out[[j]]

      value_set <- d_out$checks$value_set

      if (!is.na(value_set)){

        # initialize outlist
        outlist2 <- list()

        # parse value_set
        value_set <- jsonlite::fromJSON(value_set)

        if (d_out$checks$var_type == "factor"){
          # get valueset from mdr
          value_set <- unlist(strsplit(value_set$value_set, ", ", fixed = T))
          # get levels from results
          levels_results <-s_out[,levels(get(i))]
          # compare levels from results to constraints from valueset (TRUE = constraint_error)
          outlist2$conformance_error <- any(levels_results %!in% value_set)
          # if TRUE, get those values, that do not fit
          outlist2$conformance_results <- ifelse(isTRUE(outlist2$conformance_error),
                                                 paste0("Levels that are not conform with value_set constraints:\n", paste(levels_results[levels_results %!in% value_set], collapse = "\n")),
                                                 "No 'value conformance' issues found.")
        } else if (d_out$checks$var_type %in% c("integer", "numeric")){
          error_flag <- FALSE

          # set colnames (we need them here to correctly select the data)
          colnames(s_out) <- c("name", "value")

          # TODO add value_thresholds here as tolerance-/border zone
          result_min <- as.numeric(s_out[get("name")=="Minimum",get("value")])
          result_max <- as.numeric(s_out[get("name")=="Maximum",get("value")])

          # compare levels from results to constraints from valueset (TRUE = constraint_error)
          if (result_min < value_set$min){
            cat(paste0(i, "/ ", j, ": result_min < value_set$min\n"))
            error_flag <- TRUE
          }

          if (result_max > value_set$max){
            cat(paste0(i, "/ ", j, ": result_max > value_set$max\n"))
            error_flag <- TRUE
          }
          outlist2$conformance_error <- error_flag
          outlist2$conformance_results <- ifelse(isTRUE(error_flag),
                                                      "Extrem values are not conform with value_set constraints.",
                                                      "No 'value conformance' issues found.")
        }
        outlist[[i]][[j]] <- outlist2
      }
    }

  }

  return(outlist)
}
