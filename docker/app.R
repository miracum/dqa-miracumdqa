# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2020 Universitätsklinikum Erlangen
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

library(miRacumDQA)

print("creds1:", Sys.getenv("I2B2_PASSWORD"))
print("creds2:", Sys.getenv("OMOP_PASSWORD"))

launch_dqa_tool(
  utils_path = "/home/shiny/miracumdqa/inst/application/_utilities/",
  config_file =
    paste0("/home/shiny/miracumdqa/inst/application/",
           "_utilities/settings/settings_default.yml")
)

