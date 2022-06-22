# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2022 Universitätsklinikum Erlangen
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
  "Magdeburg" = "UMMD",
  "Marburg" = "UMR"
)

jsonlist <- toJSON(sitenamelist, pretty = TRUE, auto_unbox = FALSE)
writeLines(jsonlist, "./inst/application/_utilities/MISC/sitenames.JSON")
