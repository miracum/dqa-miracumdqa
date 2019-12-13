# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019 Universitätsklinikum Erlangen
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

# create source_system specific slots
source_slot <- function(mdr, sourcesystem, name) {

  subs <- mdr[get("source_system_name") ==
                sourcesystem & get("designation") ==
                name & get("dqa_assessment") == 1, ]

  # initialize outlist
  outlist <- list()

  outlist$base <- list(
    "dqa_assessment" = subs[, get("dqa_assessment")],
    "key" = subs[, get("key")],
    "variable_name" = subs[, get("variable_name")],
    "fhir" = subs[, get("fhir")],
    "source_variable_name" = subs[, get("source_variable_name")],
    "source_table_name" = subs[, get("source_table_name")]
  )
  if (!is.na(subs[, get("constraints")])) {
    outlist$base <- c(outlist$base, list(
      "constraints" = subs[, get("constraints")]
    ))
  }
  if (!is.na(subs[, get("value_threshold")])) {
    outlist$base <- c(outlist$base, list(
      "value_threshold" = subs[, get("value_threshold")]
    ))
  }
  if (!is.na(subs[, get("data_map")])) {
    outlist$base <- c(outlist$base, list(
      "data_map" = subs[, get("data_map")]
    ))
  }
  if (!is.na(subs[, get("sql_from")])) {
    outlist$base <- c(outlist$base, list(
      "sql_from" = subs[, get("sql_from")]
    ))
  }
  if (!is.na(subs[, get("sql_join_on")])) {
    outlist$base <- c(outlist$base, list(
      "sql_join_on" = subs[, get("sql_join_on")]
    ))
  }
  if (!is.na(subs[, get("sql_join_type")])) {
    outlist$base <- c(outlist$base, list(
      "sql_join_type" = subs[, get("sql_join_type")]
    ))
  }
  if (!is.na(subs[, get("sql_where")])) {
    outlist$base <- c(outlist$base, list(
      "sql_where" = subs[, get("sql_where")]
    ))
  }
  if (nrow(mdr[get("source_system_name") == sourcesystem &
               get("key") == subs[, get("key")] &
               get("dqa_assessment") == 0, ]) > 0) {

    helps <- mdr[get("source_system_name") == sourcesystem &
                   get("key") == subs[, get("key")] &
                   get("dqa_assessment") == 0, ]

    helpsout <- list()

    for (i in unique(helps[, get("variable_name")])) {
      helpsout[[i]] <- list(
        "dqa_assessment" = 0,
        "designation" = helps[get("variable_name") == i,
                              get("designation")],
        "source_variable_name" = helps[get("variable_name") == i,
                                       get("source_variable_name")],
        "source_table_name" = helps[get("variable_name") == i,
                                    get("source_table_name")],
        "variable_name" = helps[get("variable_name") == i,
                                get("variable_name")],
        "key" = helps[get("variable_name") == i,
                      get("key")],
        "fhir" = helps[get("variable_name") == i,
                       get("fhir")]
      )
      if (!is.na(helps[, get("sql_from")])) {
        helpsout[[i]] <- c(helpsout[[i]], list(
          "sql_from" = helps[, get("sql_from")]
        ))
      }
      if (!is.na(helps[, get("sql_join_on")])) {
        helpsout[[i]] <- c(helpsout[[i]], list(
          "sql_join_on" = helps[, get("sql_join_on")]
        ))
      }
      if (!is.na(helps[, get("sql_join_type")])) {
        helpsout[[i]] <- c(helpsout[[i]], list(
          "sql_join_type" = helps[, get("sql_join_type")]
        ))
      }
      if (!is.na(helps[, get("sql_where")])) {
        helpsout[[i]] <- c(helpsout[[i]], list(
          "sql_where" = helps[, get("sql_where")]
        ))
      }
      if (!is.na(helps[, get("plausibility_relation")])) {
        helpsout[[i]] <- c(helpsout[[i]], list(
          "plausibility_relation" = helps[, get("plausibility_relation")]
        ))
      }
    }
    outlist$helper_vars <- helpsout
  }
  return(jsonlite::toJSON(outlist))
}


# create dqa-slots
dqa_slot <- function(mdr, sourcesystem, name) {

  subs <- mdr[get("source_system_name") ==
                sourcesystem & get("designation") ==
                name & get("dqa_assessment") == 1, ]

  outlist <- list("variable_name" = subs[, get("variable_name")],
                  "fhir" = subs[, get("fhir")])
  if (!is.na(subs[, get("plausibility_relation")])) {
    outlist <- c(outlist, list(
      "plausibility_relation" = subs[, get("plausibility_relation")]
    ))
  }
  for (j in unique(mdr[, get("source_system_type")])) {
    if (!is.na(j)) {
      if (j == "") {
        next
      } else if (is.null(outlist[[j]])) {
        outlist[[j]] <- list()
      }
      for (k in unique(mdr[get("source_system_type") == j,
                           get("source_system_name")])) {
        if (!is.na(k)) {
          if (k == "") {
            next
          } else {
            outlist[[j]][[k]] <- source_slot(
              mdr = mdr,
              sourcesystem = k,
              name = name)
          }
        }
      }
    }
  }
  return(jsonlite::toJSON(outlist))
}
