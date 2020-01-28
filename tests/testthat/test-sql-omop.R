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

context("test i2b2 SQL statements")

prefix <- "./"
utildir <- paste0(prefix, "../../miRacumDQA/")

test_that(
  desc = "correct sql statments",
  code = {

  rv <- list()
  rv$sql <- DQAstats::load_sqls(
    system.file("application/_utilities/",
                package = "miRacumDQA"),
    "omop")

  expect_type(rv$sql, "list")

  # Loop over target_keys and check for hash and type
  known_hashes <- list("dt.admission" = "82e83232ef",
                       "dt.gender" = "f0b8920d07",
                       "dt.birthdate" = "d7f4bbda37",
                       "dt.zipcode" = "6947bb9e94",
                       "dt.encounterstart" = "a5bc51524f",
                       "dt.encounterend" = "2ccf876bd4",
                       "dt.conditioncategory" = "311c1ccfd7",
                       "dt.proceduredate" = "363684fbdb",
                       "dt.providerstart" = "b7b3a86a30",
                       "dt.providerend" = "c770cf3e88",
                       "dt.ageindays" = "90c488d63e",
                       "dt.ageinyears" = "c9ef48e00c",
                       "dt.condition" = "0963cbebc1",
                       "dt.discharge" = "b4d691dbb4",
                       "dt.encounter" = "ee4fc87b05",
                       "dt.hospitalization" = "5bdf8b4549",
                       "dt.patient" = "2dc2a0de0b",
                       "dt.procedure" = "e028bc6936",
                       "dt.procedure_medication" = "5e0398c307",
                       "dt.provider" = "06a54ef21c",
                       "dt.ventilation" = "7f713cc6ef")
  for (i in names(known_hashes)) {
    expect_type(rv$sql[[i]], "character")
    expect_known_hash(rv$sql[[i]], known_hashes[[i]])
  }

})
