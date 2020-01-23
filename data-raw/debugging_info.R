launch_dqa_tool(utilspath = "./_utilities/", db_source = "p21csv")


# mdr to samply
mdr_to_samply()

# export from samply
mdr <- mdr_from_samply()
data.table::fwrite(mdr, file = "inst/application/_utilities/MDR/samply_export.csv")


# debugging ffm
mdr <- mdr_from_samply(base_url = "https://test.mdr.mig-frankfurt.de/rest/api/mdr/",
                       namespace = "mdr")

