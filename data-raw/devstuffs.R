packagename <- "miRacumDQA"

# remove existing description object
unlink("DESCRIPTION")
# Create a new description object
my_desc <- desc::description$new("!new")
# Set your package name
my_desc$set("Package", packagename)
# Set author names
my_desc$set_authors(c(
  person("Lorenz A.", "Kapsner", email = "lorenz.kapsner@uk-erlangen.de", role = c("cre", "aut"),
         comment = c(ORCID = "0000-0003-1866-860X")),
  person(
    "Jonathan M.",
    "Mang",
    role = "aut",
    comment = c(ORCID = "0000-0003-0518-4710")
  ),
  person("Franziska", "Bathelt", role = "ctb"),
  person("Denis", "Gebele", role = "ctb"),
  person("MIRACUM - Medical Informatics in Research and Care in University Medicine", role = "fnd"),
  person("Universitätsklinikum Erlangen", role = "cph")
)) #,
#  person("Name2", "Surname2", email = "mail@2", role = 'aut')))
# Remove some author fields
my_desc$del("Maintainer")
# Set the version
my_desc$set_version("2.1.2.9015")
# The title of your package
my_desc$set(Title = "MIRACUM DQA Tool")
# The description of your package
my_desc$set(Description = "The MIRACUM consortium's data quality assessment tool.")
# The description of your package
my_desc$set("Date" = as.character(Sys.Date()))
# The urls
my_desc$set("URL", "https://gitlab.miracum.org/miracum/dqa/miRacumDQA")
my_desc$set("BugReports",
            "https://gitlab.miracum.org/miracum/dqa/miRacumDQA/issues")
# License
my_desc$set("License", "GPL-3")

# Reticulate
my_desc$set(
  "Config/reticulate",
  "\nlist(
    packages = list(
      list(package = \"git+https://gitlab.miracum.org/miracum/dqa/dqa-mdr-connector@add_slot_logic\")
    )
  )")


# Save everyting
my_desc$write(file = "DESCRIPTION")

# License
#usethis::use_gpl3_license(name="Universitätsklinikum Erlangen")


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
usethis::use_package("shiny", type = "Imports")
usethis::use_package("magrittr", type = "Imports")
usethis::use_package("shinydashboard", type = "Imports")
usethis::use_package("jsonlite", type = "Imports")
usethis::use_package("data.table", type = "Imports")
usethis::use_package("openxlsx", type = "Imports")
usethis::use_package("utils", type = "Imports")
usethis::use_package("influxdbr", type = "Imports")
usethis::use_package("DIZutils", type = "Imports")
usethis::use_package("DIZtools", type = "Imports")
usethis::use_package("DQAstats", type = "Imports")
usethis::use_package("reticulate", type = "Imports", min_version = "1.14")

# define remotes
remotes_append_vector <- NULL

# Development packages
utils_tag <- "cran" # e.g. "v0.1.7", "development" or "cran"
if (utils_tag == "cran") {
  remotes::update_packages("DIZutils", upgrade = "always")
} else{
  devtools::install_github("miracum/misc-dizutils", ref = utils_tag)

  add_remotes <- paste0(
    "github::miracum/misc-dizutils@", utils_tag
  )
  if (is.null(remotes_append_vector)) {
    remotes_append_vector <- add_remotes
  } else {
    remotes_append_vector <- c(remotes_append_vector, add_remotes)
  }
}

stats_tag <- "cran" # e.g. "v0.1.7", "development" or "cran"
if (stats_tag == "cran") {
  remotes::update_packages("DQAstats", upgrade = "always")
} else{
  devtools::install_git(
    url = "https://gitlab.miracum.org/miracum/dqa/dqastats.git",
    ref = stats_tag,
    upgrade = "always",
    quiet = TRUE
  )
  add_remotes <- paste0(
    "url::https://gitlab.miracum.org/miracum/dqa/dqastats/-/archive/", stats_tag, "/dqastats-", stats_tag, ".zip"
  )
  if (is.null(remotes_append_vector)) {
    remotes_append_vector <- add_remotes
  } else {
    remotes_append_vector <- c(remotes_append_vector, add_remotes)
  }
}

gui_tag <- "cran" # e.g. "v0.1.7", "development" or "cran"
if (gui_tag == "cran") {
  remotes::update_packages("DQAgui", upgrade = "always")
} else{
  devtools::install_git(
    url = "https://gitlab.miracum.org/miracum/dqa/dqagui.git",
    ref = gui_tag,
    upgrade = "always"
  )
  add_remotes <- paste0(
    "url::https://gitlab.miracum.org/miracum/dqa/dqagui/-/archive/", gui_tag, "/dqagui-", gui_tag, ".zip"
  )
  if (is.null(remotes_append_vector)) {
    remotes_append_vector <- add_remotes
  } else {
    remotes_append_vector <- c(remotes_append_vector, add_remotes)
  }
}

# finally, add remotes (if required)
if (!is.null(remotes_append_vector)) {
  desc::desc_set_remotes(
    remotes_append_vector,
    file = usethis::proj_get()
  )
}

# Suggests
usethis::use_package("testthat", type = "Suggests")
usethis::use_package("processx", type = "Suggests")
usethis::use_package("lintr", type = "Suggests")
usethis::use_package("markdown", type = "Suggests")



# buildignore and gitignore
usethis::use_build_ignore("docker")
usethis::use_build_ignore("inst/application/_utilities/MDR/XLSX/")
usethis::use_build_ignore("inst/application/_utilities/MDR/XSD/")
usethis::use_build_ignore("inst/application/_utilities/MDR/.~lock.mdr.csv#")
usethis::use_build_ignore("inst/application/_settings/")
usethis::use_build_ignore(".vscode")
usethis::use_build_ignore(".lintr")
usethis::use_build_ignore("ci/*")
usethis::use_build_ignore("NEWS.md")

usethis::use_git_ignore("inst/application/_settings/")
usethis::use_git_ignore("inst/application/_utilities/MDR/.~lock.*")
usethis::use_git_ignore("/*")
usethis::use_git_ignore("/*/")
usethis::use_git_ignore("*.log")
usethis::use_git_ignore("!/.gitignore")
usethis::use_git_ignore("!/.Rbuildignore")
usethis::use_git_ignore("!/.gitlab-ci.yml")
usethis::use_git_ignore("!/data-raw/")
usethis::use_git_ignore("!/DESCRIPTION")
usethis::use_git_ignore("!/inst/")
usethis::use_git_ignore("!/LICENSE.md")
usethis::use_git_ignore("!/man/")
usethis::use_git_ignore("!NAMESPACE")
usethis::use_git_ignore("!/R/")
usethis::use_git_ignore("!/README.md")
usethis::use_git_ignore("!/tests/")
usethis::use_git_ignore("!/*.Rproj")
usethis::use_git_ignore("/.Rhistory")
usethis::use_git_ignore("/.Rproj*")
usethis::use_git_ignore("/.RData")
usethis::use_git_ignore("!/ci/")
usethis::use_git_ignore("/.vscode")
usethis::use_git_ignore("!/.lintr")
usethis::use_git_ignore("!/NEWS.md")

# create NEWS.md using the python-package "auto-changelog" (must be installed)
# https://www.conventionalcommits.org/en/v1.0.0/
# build|ci|docs|feat|fix|perf|refactor|test
system(
  command = 'auto-changelog -u -t "miRacumDQA NEWS" --tag-prefix "v" -o "NEWS.md"'
)
