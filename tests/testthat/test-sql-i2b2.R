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
    known_hashes <- list("dt.admission" = "96c232dc35",
                         "dt.gender" = "765e2b4ce7",
                         "dt.birthdate" = "f5f9b87310",
                         "dt.zipcode" = "c66f14a5bb",
                         "dt.encounterstart" = "f0e5fb3d19",
                         "dt.encounterend" = "5286d0964f",
                         "dt.conditioncategory" = "77ee19937e",
                         "dt.proceduredate" = "1e8778d81c",
                         "dt.providerstart" = "86894e028e",
                         "dt.providerend" = "8e8ba1f648",
                         "dt.ageindays" = "50ef28991a",
                         "dt.ageinyears" = "b013274608",
                         "dt.condition" = "a7de7a2714",
                         "dt.discharge" = "c71f0b452a",
                         "dt.encounter" = "ad7183153c",
                         "dt.hospitalization" = "2fc68642bc",
                         "dt.patient" = "bd0ed9b3ea",
                         "dt.procedure" = "62e8ce5f85",
                         "dt.procedure_medication" = "a058b9ac70",
                         "dt.provider" = "209ab6a18e",
                         "dt.ventilation" = "654d4fc7fd",
                         "dt.laboratory" = "a5ecc6cd")
    for (i in names(known_hashes)) {
      print(i)
      expect_type(rv$sql[[i]], "character")
      expect_known_hash(rv$sql[[i]], known_hashes[[i]])
    }

  })
