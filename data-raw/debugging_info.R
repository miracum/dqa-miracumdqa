launch_dqa_tool(logfile_dir = "~/share/logfiles/")


devtools::load_all()
logfile_dir = tempdir()
utils_path = paste0(getwd(), "/inst/application/_utilities/")
utils::assignInNamespace(
  x = "button_mdr",
  value = button_mdr,
  ns = "DQAgui"
)
DIZutils::set_env_vars(
  paste0(
    "../",
    list.files(path = "../", pattern = "^env_INTERNAL.*")
  )
)

launch_dqa_tool(parallel = FALSE)



shiny::shinyAppDir("inst/application/")


# launch_dqa_tool(config_file = "/home/rstudio/development/Rpackages/dqa/DQAstats/tests/testthat/testdata/demo_settings_INTERNAL.yml",
#                 use_env_credentials = FALSE)

# mdr to samply
miRacumDQA:::mdr_to_samply(mdr_filename = "mdr.csv")

# export from samply
base_url = "https://mdr-test.miracum.org/rest/api/mdr/"
namespace = "dqa"
mdr <- mdr_from_samply(base_url = base_url,
                       namespace = namespace,
                       logfile_dir = logfile_dir)
data.table::fwrite(mdr, file = "inst/application/_utilities/MDR/samply_export.csv")


# debugging ffm
mdr <- mdr_from_samply(base_url = "https://mdr-test.miracum.org/rest/api/mdr/",
                       namespace = "mdr")

# debug local
mdr <- mdr_from_samply(base_url = "https://mdr.diz.uk-erlangen.de/rest/api/mdr/",
                       namespace = "dqa",
                       logfile_dir = tempdir())


test <- mdr_from_samply(base_url = "https://mdr-test.miracum.org/rest/api/mdr/",
                       namespace = "miracum1")



base_url = "https://mdr-test.miracum.org/rest/api/mdr/"
namespace = "dqa"
master_system_type = "csv"
master_system_name = "p21csv"
headless = TRUE

test <-
  mdr_from_samply(base_url = base_url,
                  namespace = namespace,
                  logfile_dir = logfile_dir)


## Test Datamap connection:
# con_res <- get_influx_connection(list(headless = TRUE, log = list("logfile_dir" = tempdir())))
# datamap = data.table::data.table(
#   site = rep("UME", 2),
#   system = rep("i2b2", 2),
#   item = c("Fallnummer", "Hauptdiagnosen (ICD)"),
#   lay_term = c("F\u00E4lle", "Diagnosen"),
#   n = c(999999, 777777)
# )
# influxdbr::influx_write(
#   con = con_res$con,
#   db = con_res$config$dbname,
#   x = datamap,
#   tag_cols = c("site", "system", "item", "lay_term"),
#   # tag_cols = c("site", "system", "item", "n"),
#   measurement = "item_counts"
# )
