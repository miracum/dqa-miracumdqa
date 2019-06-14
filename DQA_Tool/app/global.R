# (c) 2019 Lorenz Kapsner
# assign global variable here
source("./_modules/moduleConfig.R", encoding = "UTF-8")
source("./_modules/moduleDashboard.R", encoding = "UTF-8")
source("./_modules/moduleRawdata1.R", encoding = "UTF-8")
source("./_modules/moduleNumerical.R", encoding = "UTF-8")
source("./_modules/moduleCategorical.R", encoding = "UTF-8")
source("./_modules/modulePlausibility.R", encoding = "UTF-8")
source("./_modules/moduleVisualizations.R", encoding = "UTF-8")
source("./_modules/moduleReport.R", encoding = "UTF-8")
source("./_modules/moduleMDR.R", encoding = "UTF-8")

# source external functions here
# if you want to source any files with functions, do it inside the server-function, so the information will not be shared across sessions
source("./R/database.R", encoding = "UTF-8")
source("./R/dataloading.R", encoding = "UTF-8")
source("./R/app_utils.R", encoding = "UTF-8")
source("./R/statistics.R", encoding = "UTF-8")
source("./R/calc_stats.R", encoding = "UTF-8")
source("./R/utils.R", encoding = "UTF-8")
source("./R/checks.R", encoding = "UTF-8")
source("./R/report.R", encoding = "UTF-8")
source("./R/mdr_utils.R", encoding = "UTF-8")
source("./R/plausibilities.R", encoding = "UTF-8")

