# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2021 Universitätsklinikum Erlangen
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

context("test fhirgw SQL statements")

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
      paste0(prefix, "inst/application/_utilities/SQL/SQL_fhirgw.JSON")
    )
    expect_type(rv$sql, "list")

    # Loop over target_keys and check for hash and type
    known_hashes <- list(#"dt.admission" = "29ce83dfec",
                         "dt.gender" = "860207a381",
                         "dt.birthdate" = "4425528c9a",
                         "dt.zipcode" = "1a597b53a6",
                         "dt.encounterstart" = "2a0cc4d9e7",
                         "dt.encounterend" = "3f98be91a0",
                         #"dt.conditioncategory" = "c653689a53",
                         "dt.proceduredate" = "2a0681a0d2",
                         #"dt.providerstart" = "86894e028e",
                         #"dt.providerend" = "8e8ba1f648",
                         #"dt.ageindays" = "5b9bedf7ad",
                         #"dt.ageinyears" = "e5ad2dfa13",
                         "dt.condition" = "1e0ec27ced",
                         "dt.discharge" = "5bb0c83bbc",
                         "dt.encounter" = "68cb366e76",
                         "dt.hospitalization" = "6d15e5bc51",
                         "dt.patient" = "7efcf63d1b",
                         "dt.procedure" = "3031a3dc1f",
                         #"dt.procedure_medication" = "a058b9ac70",
                         #"dt.provider" = "209ab6a18e",
                         "dt.ventilation" = "76e34855c0",
                         "dt.laboratory" = "a0916cb9")
    for (i in names(known_hashes)) {
      print(i)
      expect_type(rv$sql[[i]], "character")
      expect_known_hash(rv$sql[[i]], known_hashes[[i]])
    }

  })
