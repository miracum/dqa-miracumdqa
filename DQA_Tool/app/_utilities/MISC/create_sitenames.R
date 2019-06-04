# by Lorenz Kapsner

library(jsonlite)

sitenamelist <- list(
  "Please choose sitename" = "",
  "Mannheim" = "UMM",
  "Erlangen" = "UME",
  "Frankfurt" = "GUF",
  "Freiburg" = "UKFr",
  "Gießen" = "UKGi",
  "Mainz" = "UMCMz",
  "Dresden" = "UMD",
  "Greifswald" = "UMG",
  "Magedburg" = "UMMD",
  "Marburg" = "UMR"
)

jsonlist <- toJSON(sitenamelist, pretty = T, auto_unbox = F)
writeLines(jsonlist, "./DQA_Tool/app/_utilities/MISC/sitenames.JSON")
