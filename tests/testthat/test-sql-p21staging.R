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

if (dir.exists("../../00_pkg_src")) {
  prefix <- "../../00_pkg_src/miRacumDQA/"
} else if (dir.exists("../../R")) {
  prefix <- "../../"
} else if (dir.exists("./R")) {
  prefix <- "./"
}

test_that(
  desc = "correct sql statments",
  code = {

    rv <- list()
    rv$sql <- jsonlite::fromJSON(
      paste0(prefix, "inst/application/_utilities/SQL/SQL_p21staging.JSON")
    )
    expect_type(rv$sql, "list")

    # Loop over target_keys and check for hash and type
    known_hashes <- list("dt.admission" = "349ca92085",
                         "dt.gender" = "a0537bcb41",
                         "dt.birthdate" = "b2b0538ac5",
                         "dt.zipcode" = "66151174c1",
                         "dt.encounterstart" = "d3e4a1f676",
                         "dt.encounterend" = "2573025dcc",
                         "dt.conditioncategory" = "31b2d1650b",
                         "dt.proceduredate" = "514fc78fd4",
                         "dt.providerstart" = "07dc32440f",
                         "dt.providerend" = "5faba600ff",
                         "dt.ageindays" = "c63e7a3726",
                         "dt.ageinyears" = "62d6f6853f",
                         "dt.condition" = "94b646691a",
                         "dt.discharge" = "6c4677974d",
                         "dt.encounter" = "f631ee4bb2",
                         "dt.hospitalization" = "f046977e35",
                         "dt.patient" = "6f632234c7",
                         "dt.procedure" = "c0b910ed59",
                         "dt.procedure_medication" = "bb2f353b9b",
                         "dt.provider" = "e2e55f42a2",
                         "dt.ventilation" = "be11702338",
                         "dt.laboratory" = "a552cdd46")
    for (i in names(known_hashes)) {
      print(i)
      expect_type(rv$sql[[i]], "character")
      expect_known_hash(rv$sql[[i]], known_hashes[[i]])
    }

  })
