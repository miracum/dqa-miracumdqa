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

library(data.table)

# read mdr
mdr <- fread(paste0(getwd(), "/inst/application/_utilities/MDR/mdr.csv"))
mdr[,plausibility_relation:=as.character(plausibility_relation)]
mdr[,("constraints"):=gsub("\"\"", "\"", get("constraints"))][get("constraints")=="",("constraints"):=NA]
mdr[,("plausibility_relation"):=gsub("\"\"", "\"", get("plausibility_relation"))][get("plausibility_relation")=="",("plausibility_relation"):=NA]

# Geburtsjahr
p <- jsonlite::toJSON(
  list("uniqueness" = list("patient_birthDate" = list("name" = "Pl.uniqueness.Item01",
                                                      "description" = "Mit jeder Patienten-ID darf nur ein Geburtsjahr assoziiert sein."))))
mdr[grepl("dt\\.patient_", key) & variable_name=="patient_identifier_value" & source_system=="p21csv", plausibility_relation := p]

# Fallnummer & Patientennummer
p <- jsonlite::toJSON(
  list("uniqueness" = list("patient_identifier_value" = list("name" = "Pl.uniqueness.Item02",
                                                             "description" = "Mit jeder Fallnummer darf nur eine Patienten-ID assoziiert sein."))))
mdr[grepl("dt\\.encounter_", key) & variable_name=="encounter_identifier_value" & source_system=="p21csv", plausibility_relation := p]

# Fallnummer & Diagnoseart
p <- jsonlite::toJSON(
  list("uniqueness" = list("condition_category_encounter_diagnosis" = list("name" = "Pl.uniqueness.Item03",
                                                                           "description" =  "Mit jeder Fallnummer darf nur eine Hauptdiagnose assoziiert sein.",
                                                                           "filter" = list("i2b2" = "HD",
                                                                                           "p21csv" = "HD",
                                                                                           "omop" = "44786627, 44786629")))))
mdr[grepl("dt\\.condition_", key) & variable_name=="condition_encounter_identifier_value" & source_system=="p21csv", plausibility_relation := p]

# Geschlecht & ICD-Code
p <- jsonlite::toJSON(
  list("atemporal" = list("condition_code_coding_code" = list("name" = "Pl.atemporal.Item01",
                                                              "description" = "Nur bei weiblichen Patientinnen ist eine ICD-Diagnose aus dem ICD-Kapitel XV (ICD O00-O99) (Schwangerschaft, Geburt und Wochenbett) als Krankenhausdiagnose erlaubt.",
                                                              "filter" = list("omop" = "O[0-9]", "i2b2" = "O[0-9]", "p21csv" = "O[0-9]"),
                                                              "join_crit" = "encounter_identifier_value",
                                                              "constraints" = list("value_set" = list("omop" = "w", "i2b2" = "w", "p21csv" = "w"))),
                          "condition_code_coding_code" = list("name" = "Pl.atemporal.Item02",
                                                              "description" = "Nur bei weiblichen Patientinnen sind bösartige Neubildungen der weiblichen Genitalorgane (ICD C51-C58) als Krankenhausdiagnose erlaubt.",
                                                              "filter" = list("omop" = "C5[1-8]", "i2b2" = "C5[1-8]", "p21csv" = "C5[1-8]"),
                                                              "join_crit" = "encounter_identifier_value",
                                                              "constraints" = list("value_set" =  list("omop" = "w", "i2b2" = "w", "p21csv" = "w"))),
                          "condition_code_coding_code" = list("name" = "Pl.atemporal.Item03",
                                                              "description" = "Nur bei männlichen Patienten sind bösartige Neubildungen der männlichen Genitalorgane (ICD C60-C63) als Krankenhausdiagnose erlaubt.",
                                                              "filter" = list("omop" = "C6[0-3]", "i2b2" = "C6[0-3]", "p21csv" = "C6[0-3]"),
                                                              "join_crit" = "encounter_identifier_value",
                                                              "constraints" = list("value_set" =  list("omop" = "m", "i2b2" = "m", "p21csv" = "m"))),
                          "encounter_hospitalization_class" = list("name" = "Pl.atemporal.Item04",
                                                                   "description" = "Nur bei weiblichen Patientinnen ist \'stationäre Entbindung\' als Aufnahmegrund (05) erlaubt.",
                                                                   "filter" = list("omop" = "05xx", "i2b2" = "05xx", "p21csv" = "05xx"),
                                                                   "join_crit" = "encounter_identifier_value",
                                                                   "constraints" = list("value_set" = list("omop" = "w", "i2b2" = "w", "p21csv" = "w")))))
)
mdr[grepl("dt\\.gender_", key) & variable_name=="patient_gender" & source_system=="p21csv", plausibility_relation := p]

# write mdr
fwrite(mdr, paste0(getwd(), "/inst/application/_utilities/MDR/mdr.csv"), sep = ";")

