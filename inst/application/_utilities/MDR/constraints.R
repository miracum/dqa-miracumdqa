# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2020 Universitätsklinikum Erlangen
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

library(data.table)
library(jsonlite)
# nolint start

# read mdr
mdr <- DQAstats::read_mdr(utils = "inst/application/_utilities/")
mdr[, constraints := NULL]

# Aufnahmeanlass
c <- jsonlite::toJSON(list("value_set" = "E, Z, N, R, V, A, G, B"))
mdr[designation == "Aufnahmeanlass" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Aufnahmeanlass" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Aufnahmeanlass" &
      source_system_name == "i2b2", constraints := c]
mdr[designation == "Aufnahmeanlass" &
      source_system_name == "omop", constraints := c]

# Alter (in Tagen)
c <-
  jsonlite::toJSON(list("range" = list(
    "min" = 1,
    "max" = 366,
    "unit" = "d"
  )))
mdr[designation == "Alter (in Tagen)" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Alter (in Tagen)" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Alter (in Tagen)" &
      source_system_name == "i2b2", constraints := c]
mdr[designation == "Alter (in Tagen)" &
      source_system_name == "omop", constraints := c]

# Alter (in Jahren)
c <-
  jsonlite::toJSON(list("range" = list(
    "min" = 1,
    "max" = 115,
    "unit" = "a"
  )))
mdr[designation == "Alter (in Jahren)" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Alter (in Jahren)" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Alter (in Jahren)" &
      source_system_name == "i2b2", constraints := c]
mdr[designation == "Alter (in Jahren)" &
      source_system_name == "omop", constraints := c]

# Diagnoseart
c <- jsonlite::toJSON(list("value_set" = "HD, ND"))
mdr[designation == "Diagnoseart" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Diagnoseart" &
      source_system_name == "p21staging", constraints := c]
c <-
  jsonlite::toJSON(list("value_set" = "DIAGNOSEART:HD, DIAGNOSEART:ND"))
mdr[designation == "Diagnoseart" &
      source_system_name == "i2b2", constraints := c]
c <- jsonlite::toJSON(list("value_set" = "44786627, 44786629"))
mdr[designation == "Diagnoseart" &
      source_system_name == "omop", constraints := c]

# ICD Code
c <-
  jsonlite::toJSON(
    list("regex" = "^([[:upper:]]){1}([[:digit:]]{1,2})((\\.)([[:digit:]]{1,2}))?(\\+|\\*|\\!)?$")
  )
mdr[designation == "Diagnosen (ICD)" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Diagnosen (ICD)" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Diagnosen (ICD)" &
      source_system_name == "omop", constraints := c]
c <-
  jsonlite::toJSON(
    list("regex" = "^(ICD10\\:)([[:upper:]]){1}([[:digit:]]{1,2})((\\.)([[:digit:]]{1,2}))?(\\+|\\*|\\!)?$")
  )
mdr[designation == "Diagnosen (ICD)" &
      source_system_name == "i2b2", constraints := c]

# Fallnummer
c <- jsonlite::toJSON(list("regex" = "^([[:alnum:]]){1,}"))
mdr[designation == "Fallnummer" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Fallnummer" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Fallnummer" &
      source_system_name == "i2b2", constraints := c]
mdr[designation == "Fallnummer" &
      source_system_name == "omop", constraints := c]

# Entlassungsgrund
c <- jsonlite::toJSON(list("regex" = "^([[:digit:]]{1,3})$"))
mdr[designation == "Entlassungsgrund" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Entlassungsgrund" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Entlassungsgrund" &
      source_system_name == "i2b2", constraints := c]
mdr[designation == "Entlassungsgrund" &
      source_system_name == "omop", constraints := c]

# Entlassungsdatum, Aufnahmedatum, OPS Datum, Entlassungsdatum (Fachabteilung), Aufnahmedatum (Fachabteilung)
# TODO value_set für Datumsvariablen überlegen

# Aufnahmegrund
c <- jsonlite::toJSON(list("regex" = "^([[:digit:]]{1,4})$"))
mdr[designation == "Aufnahmegrund" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Aufnahmegrund" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Aufnahmegrund" &
      source_system_name == "i2b2", constraints := c]
mdr[designation == "Aufnahmegrund" &
      source_system_name == "omop", constraints := c]

# Postleitzahl
c <- jsonlite::toJSON(list("regex" = "^([[:digit:]]{5})$"))
mdr[designation == "Postleitzahl" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Postleitzahl" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Postleitzahl" &
      source_system_name == "i2b2", constraints := c]
mdr[designation == "Postleitzahl" &
      source_system_name == "omop", constraints := c]

# Geburtsjahr
c <-
  jsonlite::toJSON(list("regex" = "^(19|20)([[:digit:]]{2})((-[[:digit:]]{2}){2})?$"))
mdr[designation == "Geburtsjahr" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Geburtsjahr" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Geburtsjahr" &
      source_system_name == "i2b2", constraints := c]
mdr[designation == "Geburtsjahr" &
      source_system_name == "omop", constraints := c]

# Geschlecht
c <- jsonlite::toJSON(list("value_set" = "m, w, x"))
mdr[designation == "Geschlecht" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Geschlecht" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Geschlecht" &
      source_system_name == "omop", constraints := c]
c <- jsonlite::toJSON(list("value_set" = "m, f, u"))
mdr[designation == "Geschlecht" &
      source_system_name == "i2b2", constraints := c]

# Patientennummer
c <- jsonlite::toJSON(list("regex" = "^([[:alnum:]]){1,}"))
mdr[designation == "Patientennummer" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Patientennummer" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Patientennummer" &
      source_system_name == "i2b2", constraints := c]
mdr[designation == "Patientennummer" &
      source_system_name == "omop", constraints := c]

# OPS Code
c <-
  jsonlite::toJSON(
    list("regex" = "^([[:digit:]]{1})(\\-)?([[:digit:]]{2})([[:lower:]]{1}|([[:digit:]]{1}))((\\.)?([[:alnum:]]){1,2})?$")
  )
mdr[designation == "Prozeduren (OPS)" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Prozeduren (OPS)" &
      source_system_name == "p21staging", constraints := c]
c <-
  jsonlite::toJSON(
    list("regex" = "^([[:digit:]]{1})(\\-)([[:digit:]]{2})([[:lower:]]{1}|([[:digit:]]{1}))((\\.)([[:alnum:]]){1,2})?$")
  )
mdr[designation == "Prozeduren (OPS)" &
      source_system_name == "omop", constraints := c]
c <-
  jsonlite::toJSON(
    list("regex" = "^(OPS\\:)([[:digit:]]{1})(\\-)([[:digit:]]{2})([[:lower:]]{1}|([[:digit:]]{1}))((\\.)([[:alnum:]]){1,2})?$")
  )
mdr[designation == "Prozeduren (OPS)" &
      source_system_name == "i2b2", constraints := c]

# Medikation (OPS Code)
c <-
  jsonlite::toJSON(
    list("regex" = "^(6(\\-)?(00))([[:lower:]]{1}|([[:digit:]]{1}))((\\.)?([[:alnum:]]){1,2})?$")
  )
mdr[designation == "Medikation (OPS)" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Medikation (OPS)" &
      source_system_name == "p21staging", constraints := c]
c <-
  jsonlite::toJSON(
    list("regex" = "^(6\\-00)([[:lower:]]{1}|([[:digit:]]{1}))((\\.)([[:alnum:]]){1,2})?$")
  )
mdr[designation == "Medikation (OPS)" &
      source_system_name == "omop", constraints := c]
c <-
  jsonlite::toJSON(
    list("regex" = "^(OPS\\:6\\-00)([[:lower:]]{1}|([[:digit:]]{1}))((\\.)([[:alnum:]]){1,2})?$")
  )
mdr[designation == "Medikation (OPS)" &
      source_system_name == "i2b2", constraints := c]

# Fachabteilung
c <- jsonlite::toJSON(list("regex" = "^([[:alnum:]]){1,}"))
mdr[designation == "Fachabteilung" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Fachabteilung" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Fachabteilung" &
      source_system_name == "i2b2", constraints := c]
mdr[designation == "Fachabteilung" &
      source_system_name == "omop", constraints := c]

# Beatmungsstunden (365.25 Tage * 24 Stunden = 8766 Stunden)
c <-
  jsonlite::toJSON(list("range" = list(
    "min" = 0,
    "max" = 8766,
    "unit" = "h"
  )))
mdr[designation == "Beatmungsstunden" &
      source_system_name == "p21csv", constraints := c]
mdr[designation == "Beatmungsstunden" &
      source_system_name == "p21staging", constraints := c]
mdr[designation == "Beatmungsstunden" &
      source_system_name == "i2b2", constraints := c]
mdr[designation == "Beatmungsstunden" &
      source_system_name == "omop", constraints := c]

# Laborwerte (LOINC) (365.25 Tage * 24 Stunden = 8766 Stunden)
c <-
  jsonlite::toJSON(list("regex" = "^[[:digit:]]{2,5}\\-[[:digit:]]{1}$"))
mdr[designation == "Laborwerte (LOINC)" &
      source_system_name == "p21staging", constraints := c]
c <-
  jsonlite::toJSON(list("regex" = "^(LOINC\\:)[[:digit:]]{2,5}\\-[[:digit:]]{1}$"))
mdr[designation == "Laborwerte (LOINC)" &
      source_system_name == "i2b2", constraints := c]

# write mdr
fwrite(mdr,
       paste0(getwd(), "/inst/application/_utilities/MDR/mdr.csv"),
       sep = ";")
# nolint end
