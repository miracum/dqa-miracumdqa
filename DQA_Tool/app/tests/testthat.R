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

library(testthat)
options(testthat.use_colours = TRUE)

library(data.table)

# source("./DQA_Tool/app/R/headless.R", encoding = "UTF-8")

test_check("testthat")

# start tests manually
# debugging prefix
# debug_prefix <- "./DQA_Tool/app/tests/"
# test_dir(debug_prefix)
test_file(paste0(debug_prefix, "testthat/test-sql-i2b2.R"))
test_file(paste0(debug_prefix, "testthat/test-dataloading.R"))
test_file(paste0(debug_prefix, "testthat/test-startup.R"))
test_file(paste0(debug_prefix, "testthat/test-headless.R"))
test_file(paste0(debug_prefix, "testthat/test-statistics.R"))
