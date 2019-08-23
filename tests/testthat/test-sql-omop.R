context("test i2b2 SQL statements")

# debugging prefix
# prefix <- "./tests/testthat/"
# utildir <- paste0(prefix, "../../inst/")
prefix <- "./"
utildir <- paste0(prefix, "../../miRacumDQA/")

test_that("correct sql statments",{

  rv <- list()
  rv$sql_target <- DQAstats::loadSQLs_(system.file("application/_utilities/", package = "miRacumDQA"), "omop")

  expect_type(rv$sql_target, "list")

  # Loop over target_keys and check for hash and type
  known_hashes <- list("dt.admission_target" = "82e83232ef",
                       "dt.gender_target" = "f0b8920d07",
                       "dt.birthdate_target" = "d7f4bbda37",
                       "dt.zipcode_target" = "6947bb9e94",
                       "dt.encounterstart_target" = "a5bc51524f",
                       "dt.encounterend_target" = "2ccf876bd4",
                       "dt.conditioncategory_target" = "311c1ccfd7",
                       "dt.proceduredate_target" = "363684fbdb",
                       "dt.providerstart_target" = "b7b3a86a30",
                       "dt.providerend_target" = "c770cf3e88",
                       "dt.ageindays_target" = "90c488d63e",
                       "dt.ageinyears_target" = "c9ef48e00c",
                       "dt.condition_target" = "0963cbebc1",
                       "dt.discharge_target" = "b4d691dbb4",
                       "dt.encounter_target" = "ee4fc87b05",
                       "dt.hospitalization_target" = "5bdf8b4549",
                       "dt.patient_target" = "2dc2a0de0b",
                       "dt.procedure_target" = "e028bc6936",
                       "dt.provider_target" = "06a54ef21c",
                       "dt.ventilation_target" = "7f713cc6ef")
  for (i in names(known_hashes)){
    expect_type(rv$sql_target[[i]], "character")
    expect_known_hash(rv$sql_target[[i]], known_hashes[[i]])
  }

})
