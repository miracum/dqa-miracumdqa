context("test i2b2 SQL statements")

# debugging prefix
# prefix <- "./tests/testthat/"
# utildir <- paste0(prefix, "../../inst/")
prefix <- "./"
utildir <- paste0(prefix, "../../miRacumDQA/")

test_that("correct sql statments",{

  rv <- list()
  rv$sql_target <- DQAstats::loadSQLs_(system.file("application/_utilities/", package = "miRacumDQA"), "i2b2")

  expect_type(rv$sql_target, "list")

  # Loop over target_keys and check for hash and type
  known_hashes <- list("dt.admission_target" = "18c5d016c9",
                       "dt.gender_target" = "556e9b677c",
                       "dt.birthdate_target" = "0ea256fecc",
                       "dt.zipcode_target" = "2b9cb2ad54",
                       "dt.encounterstart_target" = "5c820e9336",
                       "dt.encounterend_target" = "3da89429af",
                       "dt.conditioncategory_target" = "b4edcd663b",
                       "dt.proceduredate_target" = "e088420534",
                       "dt.providerstart_target" = "1014b9f09e",
                       "dt.providerend_target" = "bcc5a7623e",
                       "dt.ageindays_target" = "13b3039049",
                       "dt.ageinyears_target" = "184b4afe3a",
                       "dt.condition_target" = "aabb60fa64",
                       "dt.discharge_target" = "d30d2befdf",
                       "dt.encounter_target" = "e04436ffae",
                       "dt.hospitalization_target" = "c8b2f31dd4",
                       "dt.patient_target" = "3ed7ad8ce2",
                       "dt.procedure_target" = "e3f4c27b07",
                       "dt.provider_target" = "67eec0e3d5",
                       "dt.ventilation_target" = "cc984a2ab6")
  for (i in names(known_hashes)){
    expect_type(rv$sql_target[[i]], "character")
    expect_known_hash(rv$sql_target[[i]], known_hashes[[i]])
  }

})
