context("lints")

if (dir.exists("../../00_pkg_src")) {
  prefix <- "../../00_pkg_src/miRacumDQA/"
} else if (dir.exists("../../R")) {
  prefix <- "../../"
} else if (dir.exists("./R")) {
  prefix <- "./"
}

test_that(
  desc = "test lints",
  code = {
    lintlist <- list(
      "R" = list(
        "launch_app.R" = NULL,
        "mdr_from_samply.R" = NULL,
        "mdr_to_samply.R" = NULL,
        "mdr_converter_utils.R" = list(
          list(
            message = "cyclomatic complexity",
            line_number = 18
          ),
          list(
            message = "cyclomatic complexity",
            line_number = 120
          )
        )
      ),
      "inst/application" = list(
        "server.R" = NULL,
        "ui.R" = NULL,
        "global.R" = NULL
      ),
      "tests/testthat" = list(
        "test-lints.R" = NULL,
        "test-sql-i2b2.R" = NULL,
        "test-sql-omop.R" = NULL
      )
    )

    for (directory in names(lintlist)) {
      print(directory)
      for (fname in names(lintlist[[directory]])) {
        print(fname)
        #% print(list.files(prefix))

        # skip on covr
        skip_on_covr()

        lintr::expect_lint(
          file = paste0(
            prefix,
            directory,
            "/",
            fname
          ),
          checks = lintlist[[directory]][[fname]]
        )
      }
    }
  }
)
