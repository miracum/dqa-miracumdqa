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
  known_hashes <- list("dt.admission_target" = "5571137f21",
                       "dt.gender_target" = "556e9b677c",
                       "dt.birthdate_target" = "0ea256fecc",
                       "dt.zipcode_target" = "2b9cb2ad54",
                       "dt.encounterstart_target" = "8c13d331c0",
                       "dt.encounterend_target" = "af1053ed66",
                       "dt.conditioncategory_target" = "f4785f44ca",
                       "dt.proceduredate_target" = "f1181e508e",
                       "dt.providerstart_target" = "19a51d5640",
                       "dt.providerend_target" = "8cab3454b0",
                       "dt.ageindays_target" = "975c9c4903",
                       "dt.ageinyears_target" = "9efcac17ab",
                       "dt.condition_target" = "5aae54afbd",
                       "dt.discharge_target" = "5dbf555825",
                       "dt.encounter_target" = "e04436ffae",
                       "dt.hospitalization_target" = "49a8b3c6cc",
                       "dt.patient_target" = "3ed7ad8ce2",
                       "dt.procedure_target" = "7b7644fc5d",
                       "dt.provider_target" = "768a26127c",
                       "dt.ventilation_target" = "0af5b3ba0f")
  for (i in names(known_hashes)){
    expect_type(rv$sql_target[[i]], "character")
    expect_known_hash(rv$sql_target[[i]], known_hashes[[i]])
  }

})
