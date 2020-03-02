# launch_dqa_tool(config_file = "/home/rstudio/git-local/dqagui/inst/application/_settings/demo_settings_INTERNAL.yml",
#                 use_env_credentials = FALSE)

launch_dqa_tool(
  config_file = "/home/rstudio/development/Rpackages/dqa/DQAstats/tests/testthat/testdata/demo_settings_INTERNAL.yml",
  use_env_credentials = FALSE
)

# launch_dqa_tool(config_file = "/home/rstudio/development/Rpackages/dqa/DQAstats/tests/testthat/testdata/demo_settings_INTERNAL.yml",
#                 use_env_credentials = FALSE)

# mdr to samply
mdr_to_samply()

# export from samply
mdr <- mdr_from_samply()
data.table::fwrite(mdr, file = "inst/application/_utilities/MDR/samply_export.csv")


# debugging ffm
mdr <- mdr_from_samply(base_url = "https://test.mdr.mig-frankfurt.de/rest/api/mdr/",
                       namespace = "mdr")


test <- mdr_from_samply(base_url = "https://mdr.miracum.de/rest/api/mdr/",
                       namespace = "miracum1")
