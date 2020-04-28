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
      paste0(prefix, "inst/application/_utilities/SQL/SQL_i2b2.JSON")
    )
    expect_type(rv$sql, "list")

    # Loop over target_keys and check for hash and type
    known_hashes <- list("dt.admission" = "29ce83dfec",
                         "dt.gender" = "aa7efa52d6",
                         "dt.birthdate" = "f5f9b87310",
                         "dt.zipcode" = "c66f14a5bb",
                         "dt.encounterstart" = "9350e8a7ef",
                         "dt.encounterend" = "9476a8b433",
                         "dt.conditioncategory" = "c653689a53",
                         "dt.proceduredate" = "1e8778d81c",
                         "dt.providerstart" = "86894e028e",
                         "dt.providerend" = "8e8ba1f648",
                         "dt.ageindays" = "00f4fb0031",
                         "dt.ageinyears" = "32ceca2956",
                         "dt.condition" = "ad4ac147ee",
                         "dt.discharge" = "5fc46a4bbb",
                         "dt.encounter" = "ad7183153c",
                         "dt.hospitalization" = "7c3ad87b00",
                         "dt.patient" = "bd0ed9b3ea",
                         "dt.procedure" = "2359ff28b3",
                         "dt.procedure_medication" = "351e468e1e",
                         "dt.provider" = "b2ee3dbec0",
                         "dt.ventilation" = "ab8dc07893",
                         "dt.laboratory" = "a5ecc6cd")
    for (i in names(known_hashes)) {
      print(i)
      expect_type(rv$sql[[i]], "character")
      expect_known_hash(rv$sql[[i]], known_hashes[[i]])
    }

  })
