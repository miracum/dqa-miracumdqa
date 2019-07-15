# miRacumDQA - The MIRACUM consortium's data quality assessment tool.
# Copyright (C) 2019 MIRACUM - Medical Informatics in Research and Medicine
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# assign global variable here
source("./_modules/moduleConfig.R", encoding = "UTF-8")
source("./_modules/moduleDashboard.R", encoding = "UTF-8")
source("./_modules/moduleRawdata1.R", encoding = "UTF-8")
source("./_modules/moduleDescriptive.R", encoding = "UTF-8")
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

