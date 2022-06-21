#launch_dqa_tool(logfile_dir = "~/share/logfiles/")


devtools::load_all()
logfile_dir = tempdir()
utils_path = paste0(getwd(), "/inst/application/_utilities/")
utils::assignInNamespace(
  x = "button_mdr",
  value = button_mdr,
  ns = "DQAgui"
)
DIZtools::setenv_file(
  paste0(
    "../",
    list.files(path = "../", pattern = "^env_INTERNAL.*")
  )
)

# options(shiny.trace = TRUE)
# options(shiny.fullstacktrace = TRUE)
launch_dqa_tool(parallel = TRUE)


# shiny::shinyAppDir("inst/application/", options = list(display.mode = "showcase"))

# rv <- DQAstats::dqa(
#   source_system_name = "i2b2",
#   target_system_name = "i2b2",
#   utils_path = system.file("application/_utilities/", package = "miRacumDQA"),
#   mdr_filename = "mdr.csv",
#   output_dir = "./output",
#   logfile_dir = tempdir()
# );
# rv[["sitename"]] <- "UME";
# miRacumDQA:::send_datamap_to_influx(rv)


# launch_dqa_tool(config_file = "/home/rstudio/development/Rpackages/dqa/DQAstats/tests/testthat/testdata/demo_settings_INTERNAL.yml",
#                 use_env_credentials = FALSE)
#
# # mdr to samply
# miRacumDQA:::mdr_to_samply(mdr_filename = "mdr.csv")
#
# # export from samply
# base_url = "https://mdr-test.miracum.org/rest/api/mdr/"
# namespace = "dqa"
# mdr <- mdr_from_samply(base_url = base_url,
#                        namespace = namespace,
#                        logfile_dir = logfile_dir)
# data.table::fwrite(mdr, file = "inst/application/_utilities/MDR/samply_export.csv")
#
#
# # debugging ffm
# mdr <- mdr_from_samply(base_url = "https://mdr-test.miracum.org/rest/api/mdr/",
#                        namespace = "mdr")
#
# # debug local
# mdr <- mdr_from_samply(base_url = "https://mdr.diz.uk-erlangen.de/rest/api/mdr/",
#                        namespace = "dqa",
#                        logfile_dir = tempdir())
#
#
# test <- mdr_from_samply(base_url = "https://mdr-test.miracum.org/rest/api/mdr/",
#                        namespace = "miracum1")
#
#
#
# base_url = "https://mdr-test.miracum.org/rest/api/mdr/"
# namespace = "dqa"
# master_system_type = "csv"
# master_system_name = "p21csv"
# headless = TRUE
#
# test <-
#   mdr_from_samply(base_url = base_url,
#                   namespace = namespace,
#                   logfile_dir = logfile_dir)
#
#
# ## Test Datamap connection:
# # con_res <- get_influx_connection(list(headless = TRUE, log = list("logfile_dir" = tempdir())))
# # datamap = data.table::data.table(
# #   site = rep("UME", 2),
# #   system = rep("i2b2", 2),
# #   item = c("Fallnummer", "Hauptdiagnosen (ICD)"),
# #   lay_term = c("F\u00E4lle", "Diagnosen"),
# #   n = c(999999, 777777)
# # )
# # influxdbr::influx_write(
# #   con = con_res$con,
# #   db = con_res$config$dbname,
# #   x = datamap,
# #   tag_cols = c("site", "system", "item", "lay_term"),
# #   # tag_cols = c("site", "system", "item", "n"),
# #   measurement = "item_counts"
# # )

## For datamap debugging:
# item_counts,site=ume,lay_term=Patienten,item=Patientennummer,system=i2b2 n=515477
# item_counts,site=ume,lay_term=Fälle,item=Fallnummer,system=i2b2 n=3060658
# item_counts,site=ume,lay_term=Diagnosen,item=Hauptdiagnosen\ (ICD),system=i2b2 n=6932622
# item_counts,site=ume,lay_term=Nebendiagnosen,item=Nebendiagnosen\ (ICD),system=i2b2 n=1234
