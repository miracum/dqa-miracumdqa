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
  known_hashes <- list("dt.admission_target" = "6691b03cbb",
                       "dt.gender_target" = "f0b8920d07",
                       "dt.birthdate_target" = "d7f4bbda37",
                       "dt.zipcode_target" = "6947bb9e94",
                       "dt.encounterstart_target" = "b4334f895c",
                       "dt.encounterend_target" = "3cfac97baa",
                       "dt.conditioncategory_target" = "f4785f44ca",
                       "dt.proceduredate_target" = "1ec2cded6a",
                       "dt.providerstart_target" = "c066f495fb",
                       "dt.providerend_target" = "21cddcb740",
                       "dt.ageindays_target" = "a003c23e2f",
                       "dt.ageinyears_target" = "c3e2577917",
                       "dt.condition_target" = "5aae54afbd",
                       "dt.discharge_target" = "6fe2d76111",
                       "dt.encounter_target" = "ee4fc87b05",
                       "dt.hospitalization_target" = "62c0b350b7",
                       "dt.patient_target" = "2dc2a0de0b",
                       "dt.procedure_target" = "7b7644fc5d",
                       "dt.provider_target" = "768a26127c",
                       "dt.ventilation_target" = "c2a32c0b96")
  for (i in names(known_hashes)){
    expect_type(rv$sql_target[[i]], "character")
    expect_known_hash(rv$sql_target[[i]], known_hashes[[i]])
  }

})
