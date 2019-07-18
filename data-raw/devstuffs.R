packagename <- "miRacumDQA"

# remove existing description object
unlink("DESCRIPTION")
# Create a new description object
my_desc <- desc::description$new("!new")
# Set your package name
my_desc$set("Package", packagename)
# Set author names
my_desc$set_authors(c(
  person("Lorenz", "Kapsner", email = "lorenz.kapsner@uk-erlangen.de", role = c('cre', 'aut')))) #,
#  person("Name2", "Surname2", email = "mail@2", role = 'aut')))
# Set copyright
my_desc$set("Copyright", "MIRACUM - Medical Informatics in Research and Medicine")
# Remove some author fields
my_desc$del("Maintainer")
# Set the version
my_desc$set_version("1.3.0.9000")
# The title of your package
my_desc$set(Title = "MIRACUM DQA Tool")
# The description of your package
my_desc$set(Description = "The MIRACUM consortium's data quality assessment tool.")
# The description of your package
my_desc$set("Date/Publication" = paste(as.character(Sys.time()), "UTC"))
# The urls
my_desc$set("URL", "https://gitlab.miracum.org/miracum-dqa/miRacumDQA")
my_desc$set("BugReports",
            "https://gitlab.miracum.org/miracum-dqa/miRacumDQA/issues")
# License
my_desc$set("License", "GPL-3")
# Save everyting
my_desc$write(file = "DESCRIPTION")

# License
usethis::use_gpl3_license(name="MIRACUM - Medical Informatics in Research and Medicine")


# add Imports and Depends
# Listing a package in either Depends or Imports ensures that it’s installed when needed
# Imports just loads the package, Depends attaches it
# Loading will load code, data and any DLLs; register S3 and S4 methods; and run the .onLoad() function.
##      After loading, the package is available in memory, but because it’s not in the search path,
##      you won’t be able to access its components without using ::.
##      Confusingly, :: will also load a package automatically if it isn’t already loaded.
##      It’s rare to load a package explicitly, but you can do so with requireNamespace() or loadNamespace().
# Attaching puts the package in the search path. You can’t attach a package without first loading it,
##      so both library() or require() load then attach the package.
##      You can see the currently attached packages with search().

# Depends

# Imports
usethis::use_package("data.table", type="Imports")
usethis::use_package("shiny", type="Imports")
usethis::use_package("shinydashboard", type="Imports")
usethis::use_package("shinyFiles", type="Imports")
usethis::use_package("shinyjs", type="Imports")
usethis::use_package("ggplot2", type="Imports")
usethis::use_package("magrittr", type="Imports")
usethis::use_package("stats", type="Imports")
usethis::use_package("graphics", type="Imports")
usethis::use_package("ggpubr", type="Imports")
usethis::use_package("DT", type="Imports")
usethis::use_package("jsonlite", type="Imports")
usethis::use_package("RPostgres", type="Imports")
usethis::use_package("DBI", type="Imports")
usethis::use_package("e1071", type="Imports")
usethis::use_package("knitr", type="Imports")
usethis::use_package("rmarkdown", type="Imports")
usethis::use_package("config", type="Imports")
usethis::use_package("kableExtra", type="Imports")

# Suggests
usethis::use_package("testthat", type = "Suggests")
usethis::use_package("processx", type = "Suggests")


# buildignore and gitignore
usethis::use_build_ignore("docker")
usethis::use_build_ignore("inst/application/_settings/")
usethis::use_git_ignore("inst/application/_settings/")