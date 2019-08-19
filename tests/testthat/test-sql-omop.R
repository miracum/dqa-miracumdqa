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
  known_hashes <- list("dt.admission_target" = "169f785663",
                       "dt.gender_target" = "f0b8920d07",
                       "dt.birthdate_target" = "d7f4bbda37",
                       "dt.zipcode_target" = "6947bb9e94",
                       "dt.encounterstart_target" = "3519dc620d",
                       "dt.encounterend_target" = "06f9f5d08c",
                       "dt.conditioncategory_target" = "25803faa6e",
                       "dt.proceduredate_target" = "7cc8580fa7",
                       "dt.providerstart_target" = "4736eba57f",
                       "dt.providerend_target" = "a523b67b4c",
                       "dt.ageindays_target" = "d1b917ae30",
                       "dt.ageinyears_target" = "86d836b4a2",
                       "dt.condition_target" = "af5e4a731a",
                       "dt.discharge_target" = "7811367b82",
                       "dt.encounter_target" = "ee4fc87b05",
                       "dt.hospitalization_target" = "0e0c909387",
                       "dt.patient_target" = "2dc2a0de0b",
                       "dt.procedure_target" = "f46dcba968",
                       "dt.provider_target" = "09fc1d07e0",
                       "dt.ventilation_target" = "a1169c2343")
  for (i in names(known_hashes)){
    expect_type(rv$sql_target[[i]], "character")
    expect_known_hash(rv$sql_target[[i]], known_hashes[[i]])
  }

})
