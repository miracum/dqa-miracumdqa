launch_dqa_tool(logfile_dir = "~/share/logfiles/")


devtools::load_all()
logfile_dir = tempdir()
utils_path = paste0(getwd(), "/inst/application/_utilities/")
utils::assignInNamespace(
  x = "button_mdr",
  value = button_mdr,
  ns = "DQAgui"
)
DIZutils::set_env_vars("../env_INTERNAL")
shiny::shinyAppDir("inst/application/")


DIZutils::set_env_vars("../env_INTERNAL")
launch_dqa_tool()



# launch_dqa_tool(config_file = "/home/rstudio/development/Rpackages/dqa/DQAstats/tests/testthat/testdata/demo_settings_INTERNAL.yml",
#                 use_env_credentials = FALSE)

# mdr to samply
miRacumDQA:::mdr_to_samply()

# export from samply
mdr <- mdr_from_samply()
data.table::fwrite(mdr, file = "inst/application/_utilities/MDR/samply_export.csv")


# debugging ffm
mdr <- mdr_from_samply(base_url = "https://test.mdr.mig-frankfurt.de/rest/api/mdr/",
                       namespace = "mdr")


test <- mdr_from_samply(base_url = "https://mdr.miracum.de/rest/api/mdr/",
                       namespace = "miracum1")



base_url = "https://mdr.miracum.de/rest/api/mdr/"
namespace = "dqa"
master_system_type = "csv"
master_system_name = "p21csv"
headless = TRUE

test <- mdr_from_samply(namespace = "miracum1")
