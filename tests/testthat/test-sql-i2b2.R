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

context("test i2b2 SQL statements")

prefix <- "./"
utildir <- paste0(prefix, "../../miRacumDQA/")

test_that(
  desc = "correct sql statments",
  code = {

  rv <- list()
  rv$sql_target <- DQAstats::load_sqls(
    system.file("application/_utilities/",
                package = "miRacumDQA"),
    "i2b2")

  expect_type(rv$sql_target, "list")

  # Loop over target_keys and check for hash and type
  known_hashes <- list("dt.admission_target" = "8668a876f1",
                       "dt.gender_target" = "765e2b4ce7",
                       "dt.birthdate_target" = "f5f9b87310",
                       "dt.zipcode_target" = "c66f14a5bb",
                       "dt.encounterstart_target" = "19243c5c15",
                       "dt.encounterend_target" = "f9b91db099",
                       "dt.conditioncategory_target" = "8e0b0824bd",
                       "dt.proceduredate_target" = "83252f50de",
                       "dt.providerstart_target" = "78841ad143",
                       "dt.providerend_target" = "1848705f06",
                       "dt.ageindays_target" = "50ef28991a",
                       "dt.ageinyears_target" = "b013274608",
                       "dt.condition_target" = "a7de7a2714",
                       "dt.discharge_target" = "f7883911f5",
                       "dt.encounter_target" = "f3f149a5f1",
                       "dt.hospitalization_target" = "21636f1b75",
                       "dt.patient_target" = "bd0ed9b3ea",
                       "dt.procedure_target" = "1451a3af3a",
                       "dt.provider_target" = "6c66504624",
                       "dt.ventilation_target" = "654d4fc7fd")
  for (i in names(known_hashes)) {
    expect_type(rv$sql_target[[i]], "character")
    expect_known_hash(rv$sql_target[[i]], known_hashes[[i]])
  }

})
