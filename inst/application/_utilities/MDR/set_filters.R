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

library(data.table)

# read mdr
mdr <- DQAstats::read_mdr(utils = "inst/application/_utilities/")
mdr[, filter := as.character(filter)]
mdr[, filter := NA]

# Medikation (OPS Code)
f <- jsonlite::toJSON(
  list("filter_var" = "procedure_code_coding_code",
       "filter_logic" = "OPS\\:6\\-00")
)
mdr[grepl("dt\\.procedure_medication", key) & variable_name=="procedure_code_coding_code" & source_system_name=="p21csv" & dqa_assessment == 1, filter := f]

# write mdr
fwrite(mdr, paste0(getwd(), "/inst/application/_utilities/MDR/mdr.csv"), sep = ";")
