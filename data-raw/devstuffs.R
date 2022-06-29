# nolint start
packagename <- "miRacumDQA"

# remove existing description object
unlink("DESCRIPTION")
# Create a new description object
my_desc <- desc::description$new("!new")
# Set your package name
my_desc$set("Package", packagename)
# Set author names
my_desc$set_authors(c(
  person(
    given = "Lorenz A.",
    family = "Kapsner",
    email = "lorenz.kapsner@uk-erlangen.de",
    role = c("cre", "aut"),
    comment = c(ORCID = "0000-0003-1866-860X")
  ),
  person(
    given = "Jonathan M.",
    family = "Mang",
    email = "jonathan.mang@uk-erlangen.de",
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
my_desc$set_version("3.0.1")
# The title of your package
my_desc$set(Title = "MIRACUM DQA Tool")
# The description of your package
my_desc$set(Description = "The MIRACUM consortium's data quality assessment tool.")
# The description of your package
my_desc$set("Date" = as.character(Sys.Date()))
# The urls
my_desc$set("URL", "https://github.com/miracum/dqa-miracumdqa")
my_desc$set("BugReports",
            "https://github.com/miracum/dqa-miracumdqa/issues")
# License
my_desc$set("License", "GPL-3")

# Reticulate
my_desc$set(
  "Config/reticulate",
  "\nlist(
    packages = list(
      list(package = \"git+https://github.com/miracum/dqa-mdr-connector\")
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
usethis::use_package("data.table", type = "Imports")
usethis::use_package("utils", type = "Imports")
usethis::use_package("influxdbr", type = "Imports")
usethis::use_package("DIZtools", type = "Imports", min_version = "0.0.5")
usethis::use_package("DIZutils", type = "Imports", min_version = "0.1.1")
usethis::use_package("DQAstats", type = "Imports", min_version = "0.3.1")
usethis::use_package("DQAgui", type = "Imports", min_version = "0.2.1")
usethis::use_package("reticulate", type = "Imports", min_version = "1.14")

# define remotes
remotes_append_vector <- NULL

# Development packages
tools_tag <- "cran" # e.g. "v0.1.7", "development" or "cran"
if (tools_tag == "cran") {
  install.packages("DIZtools")
} else{
  devtools::install_github("miracum/misc-diztools", ref = tools_tag)

  add_remotes <- paste0(
    "github::miracum/misc-diztools@", tools_tag
  )
  if (is.null(remotes_append_vector)) {
    remotes_append_vector <- add_remotes
  } else {
    remotes_append_vector <- c(remotes_append_vector, add_remotes)
  }
}

utils_tag <- "cran" # e.g. "v0.1.7", "development" or "cran"
if (utils_tag == "cran") {
  install.packages("DIZutils")
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
  install.packages("DQAstats")
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
  install.packages("DQAgui")
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
usethis::use_package("lintr", type = "Suggests")



# buildignore and gitignore
usethis::use_build_ignore("docker")
usethis::use_build_ignore("inst/application/_utilities/MDR/XLSX/")
usethis::use_build_ignore("inst/application/_utilities/MDR/XSD/")
usethis::use_build_ignore("inst/application/_utilities/MDR/.~lock.mdr.csv#")
usethis::use_build_ignore("inst/application/_settings/")
usethis::use_build_ignore(".vscode")
usethis::use_build_ignore(".lintr")
usethis::use_build_ignore("ci/*")
usethis::use_build_ignore(".github*")
usethis::use_build_ignore("NEWS.md")
usethis::use_build_ignore("man/figures")
usethis::use_build_ignore("Rplots.pdf")
usethis::use_build_ignore("miRacumDQA.png")
usethis::use_build_ignore("tic.R")

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
usethis::use_git_ignore("!/.github/")
usethis::use_git_ignore("!/tic.R")

# create NEWS.md using the python-package "auto-changelog" (must be installed)
# https://www.conventionalcommits.org/en/v1.0.0/
# build|ci|docs|feat|fix|perf|refactor|test

# https://github.com/gitpython-developers/GitPython/issues/1016#issuecomment-1104114129
system(
  command = paste0("git config --global --add safe.directory ", getwd())
)

system(
  command = 'auto-changelog -u -t "miRacumDQA NEWS" --tag-prefix "v" -o "NEWS.md"'
)


# imgurl <- path.expand("~/development/Rpackages/bg5.jpeg")
# hexSticker::sticker(
#   subplot = imgurl,
#   package = "miRacumDQA",
#   s_width = 0.66,
#   s_height = 0.66,
#   s_x = 1,
#   s_y = 1,
#   p_size = 14.5,
#   p_x = 1,
#   p_y = 1.3,
#   filename = "man/figures/logo.png",
#   h_color = "#1b2259", # "#b4f2e9",
#   p_color = "#1b2259", # "#b4f2e9",
#   h_size = 0.8,
#   h_fill = "#36ffd6",
#   spotlight = TRUE,
#   #l_width = 6,
#   #l_height = 6,
#   white_around_sticker = FALSE,
#   asp = 1
# )

# nolint end
