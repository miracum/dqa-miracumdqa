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
  known_hashes <- list("dt.admission_target" = "8198d80cde",
                       "dt.gender_target" = "556e9b677c",
                       "dt.birthdate_target" = "0ea256fecc",
                       "dt.zipcode_target" = "2b9cb2ad54",
                       "dt.encounterstart_target" = "221bd12034",
                       "dt.encounterend_target" = "21940b328f",
                       "dt.conditioncategory_target" = "1a3049afbc",
                       "dt.proceduredate_target" = "0b9933c396",
                       "dt.providerstart_target" = "0e49175b01",
                       "dt.providerend_target" = "9dc46cd975",
                       "dt.ageindays_target" = "e1647fc283",
                       "dt.ageinyears_target" = "e25fd4fabb",
                       "dt.condition_target" = "d32784c9f6",
                       "dt.discharge_target" = "e4ec9539b8",
                       "dt.encounter_target" = "e04436ffae",
                       "dt.hospitalization_target" = "fd77171844",
                       "dt.patient_target" = "3ed7ad8ce2",
                       "dt.procedure_target" = "50e04be749",
                       "dt.provider_target" = "51541f137f",
                       "dt.ventilation_target" = "2c7f68e3ec")
  for (i in names(known_hashes)){
    expect_type(rv$sql_target[[i]], "character")
    expect_known_hash(rv$sql_target[[i]], known_hashes[[i]])
  }

})
