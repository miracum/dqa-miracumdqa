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
mdr[,plausibility_check:=as.character(plausibility_check)]
mdr[,plausibility_relation:=as.character(plausibility_relation)]
mdr[,("value_set"):=gsub("\"\"", "\"", get("value_set"))][get("value_set")=="",("value_set"):=NA]
mdr[,("plausibility_relation"):=gsub("\"\"", "\"", get("plausibility_relation"))][get("plausibility_relation")=="",("plausibility_relation"):=NA]

# Geburtsjahr
mdr[grepl("dt\\.patient_", key) & variable_name=="patient_identifier_value" & source_system=="csv", plausibility_relation := paste0('{"uniqueness": {"patient_birthDate": {"name": "Pl.uniqueness.Item01", ',
                                                                                                          '"description": "Mit jeder Patienten-ID darf nur ein Geburtsjahr assoziiert sein."}',
                                                                                                          '}}')]
mdr[grepl("dt\\.patient_", key) & variable_name=="patient_identifier_value" & source_system=="i2b2", plausibility_relation := paste0('{"uniqueness": {"patient_birthDate": {"name": "Pl.uniqueness.Item01", ',
                                                                                                           '"description": "Mit jeder Patienten-ID darf nur ein Geburtsjahr assoziiert sein."}',
                                                                                                           '}}')]

# Fallnummer & Patientennummer
mdr[grepl("dt\\.encounter_", key) & variable_name=="encounter_identifier_value" & source_system=="csv", plausibility_relation := paste0('{"uniqueness": {"patient_identifier_value": {"name": "Pl.uniqueness.Item02", ',
                                                                                                     '"description": "Mit jeder Fallnummer darf nur eine Patienten-ID assoziiert sein."}',
                                                                                                     '}}')]
mdr[grepl("dt\\.encounter_", key) & variable_name=="encounter_identifier_value" & source_system=="i2b2", plausibility_relation := paste0('{"uniqueness": {"patient_identifier_value": {"name": "Pl.uniqueness.Item02", ',
                                                                                                      '"description": "Mit jeder Fallnummer darf nur eine Patienten-ID assoziiert sein."}',
                                                                                                      '}}')]

# Fallnummer & Diagnoseart
mdr[grepl("dt\\.condition_", key) & variable_name=="condition_encounter_identifier_value" & source_system=="csv", plausibility_relation := paste0('{"uniqueness": {"condition_category_encounter_diagnosis": {"name": "Pl.uniqueness.Item03", ',
                                                                                                              '"description": "Mit jeder Fallnummer darf nur eine Hauptdiagnose assoziiert sein.", ',
                                                                                                              '"filter": "HD"}',
                                                                                                              '}}')]
mdr[grepl("dt\\.condition_", key) & variable_name=="condition_encounter_identifier_value" & source_system=="i2b2", plausibility_relation := paste0('{"uniqueness": {"condition_category_encounter_diagnosis": {"name": "Pl.uniqueness.Item03", ',
                                                                                                               '"description": "Mit jeder Fallnummer darf nur eine Hauptdiagnose assoziiert sein.", ',
                                                                                                               '"filter": "HD"}',
                                                                                                               '}}')]

# Geschlecht & ICD-Code
mdr[grepl("dt\\.gender_", key) & variable_name=="patient_gender" & source_system=="csv", plausibility_relation := paste0('{"atemporal": {"condition_code_coding_code": {"name": "Pl.atemporal.Item01", ',
                                                                                                                         '"description": "Nur bei weiblichen Patientinnen ist eine ICD-Diagnose aus dem ICD-Kapitel XV (ICD O00-O99) (Schwangerschaft, Geburt und Wochenbett) als Krankenhausdiagnose erlaubt.", ',
                                                                                                                         '"filter": "O[0-9]", ',
                                                                                                                         '"join_crit": "encounter_identifier_value", ',
                                                                                                                         '"checks": {"value_set": "w"}}, ',
                                                                                                                         '"condition_code_coding_code": {"name": "Pl.atemporal.Item02", ',
                                                                                                                         '"description": "Nur bei weiblichen Patientinnen sind bösartige Neubildungen der weiblichen Genitalorgane (ICD C51-C58) als Krankenhausdiagnose erlaubt.", ',
                                                                                                                         '"filter": "C5[1-8]", ',
                                                                                                                         '"join_crit": "encounter_identifier_value", ',
                                                                                                                         '"checks": {"value_set": "w"}}, ',
                                                                                                                         '"condition_code_coding_code": {"name": "Pl.atemporal.Item03", ',
                                                                                                                         '"description": "Nur bei männlichen Patienten sind bösartige Neubildungen der männlichen Genitalorgane (ICD C60-C63) als Krankenhausdiagnose erlaubt.", ',
                                                                                                                         '"filter": "C6[0-3]", ',
                                                                                                                         '"join_crit": "encounter_identifier_value", ',
                                                                                                                         '"checks": {"value_set": "m"}}, ',
                                                                                                                         '"encounter_hospitalization_class": {"name": "Pl.atemporal.Item04", ',
                                                                                                                         '"description": "Nur bei weiblichen Patientinnen ist \'stationäre Entbindung\' als Aufnahmegrund (05) erlaubt.", ',
                                                                                                                         '"filter": "05xx", ',
                                                                                                                         '"join_crit": "encounter_identifier_value", ',
                                                                                                                         '"checks": {"value_set": "w"}}',
                                                                                                                         '}}')]
mdr[grepl("dt\\.gender_", key) & variable_name=="patient_gender" & source_system=="i2b2", plausibility_relation := paste0('{"atemporal": {"condition_code_coding_code": {"name": "Pl.atemporal.Item01", ',
                                                                                                                          '"description": "Nur bei weiblichen Patientinnen ist eine ICD-Diagnose aus dem ICD-Kapitel XV (ICD O00-O99) (Schwangerschaft, Geburt und Wochenbett) als Krankenhausdiagnose erlaubt.", ',
                                                                                                                          '"filter": "O[0-9]", ',
                                                                                                                          '"join_crit": "encounter_identifier_value", ',
                                                                                                                          '"checks": {"value_set": "w"}}, ',
                                                                                                                          '"condition_code_coding_code": {"name": "Pl.atemporal.Item02", ',
                                                                                                                          '"description": "Nur bei weiblichen Patientinnen sind bösartige Neubildungen der weiblichen Genitalorgane (ICD C51-C58) als Krankenhausdiagnose erlaubt.", ',
                                                                                                                          '"filter": "C5[1-8]", ',
                                                                                                                          '"join_crit": "encounter_identifier_value", ',
                                                                                                                          '"checks": {"value_set": "w"}}, ',
                                                                                                                          '"condition_code_coding_code": {"name": "Pl.atemporal.Item03", ',
                                                                                                                          '"description": "Nur bei männlichen Patienten sind bösartige Neubildungen der männlichen Genitalorgane (ICD C60-C63) als Krankenhausdiagnose erlaubt.", ',
                                                                                                                          '"filter": "C6[0-3]", ',
                                                                                                                          '"join_crit": "encounter_identifier_value", ',
                                                                                                                          '"checks": {"value_set": "m"}}, ',
                                                                                                                          '"encounter_hospitalization_class": {"name": "Pl.atemporal.Item04", ',
                                                                                                                          '"description": "Nur bei weiblichen Patientinnen ist \'stationäre Entbindung\' als Aufnahmegrund (05) erlaubt.", ',
                                                                                                                          '"filter": "05xx", ',
                                                                                                                          '"join_crit": "encounter_identifier_value", ',
                                                                                                                          '"checks": {"value_set": "w"}}',
                                                                                                                          '}}')]

# write mdr
fwrite(mdr, paste0(getwd(), "/inst/application/_utilities/MDR/mdr.csv"), sep = ";")

