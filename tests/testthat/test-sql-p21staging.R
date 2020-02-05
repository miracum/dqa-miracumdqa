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

context("test p21staging SQL statements")

prefix <- "./"
utildir <- paste0(prefix, "../../miRacumDQA/")

test_that(
  desc = "correct sql statments",
  code = {

  rv <- list()
  rv$sql <- DQAstats::load_sqls(
    system.file("application/_utilities/",
                package = "miRacumDQA"),
    "p21staging")

  expect_type(rv$sql, "list")

  # Loop over target_keys and check for hash and type
  known_hashes <- list("dt.admission" = "f224eaf989",
                       "dt.gender" = "edd19eda6e",
                       "dt.birthdate" = "3b31759970",
                       "dt.zipcode" = "7f5ad03318",
                       "dt.encounterstart" = "5d21acab7a",
                       "dt.encounterend" = "09ab284624",
                       "dt.conditioncategory" = "31b2d1650b",
                       "dt.proceduredate" = "514fc78fd4",
                       "dt.providerstart" = "07dc32440f",
                       "dt.providerend" = "5faba600ff",
                       "dt.ageindays" = "3bd0da156d",
                       "dt.ageinyears" = "6f34828d22",
                       "dt.condition" = "94b646691a",
                       "dt.discharge" = "ffd57d2673",
                       "dt.encounter" = "764f06f3a4",
                       "dt.hospitalization" = "5cb5b6b39c",
                       "dt.patient" = "12f3af4496",
                       "dt.procedure" = "c0b910ed59",
                       "dt.procedure_medication" = "bb2f353b9b",
                       "dt.provider" = "e2e55f42a2",
                       "dt.ventilation" = "5843ba4aad")
  for (i in names(known_hashes)) {
    print(i)
    expect_type(rv$sql[[i]], "character")
    expect_known_hash(rv$sql[[i]], known_hashes[[i]])
  }

})
