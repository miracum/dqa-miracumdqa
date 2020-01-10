launch_dqa_tool(utilspath = "./_utilities/", db_source = "p21csv")


# export from samply
mdr <- mdr_from_samply()
data.table::fwrite(mdr, file = "inst/application/_utilities/MDR/samply_export.csv")
