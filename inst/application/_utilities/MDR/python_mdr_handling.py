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

import os
import pandas as pd

class MDRHandling():
  
  def __init__(self, mdr_file = "mdr.csv", csv_separator:str = ";"):
    """
    Instantiate some basics.
    """
    self.base_dir = os.path.abspath(os.path.dirname(__file__))
    
    self.csv_separator = csv_separator
    
    
    self.mdr_path = os.path.join(
      self.base_dir,
      mdr_file
    )
    
    self.mdr = pd.read_csv(
      filepath_or_buffer=self.mdr_path,
      sep=self.csv_separator,
      dtype=str,
      keep_default_na = False # read missings as empty string
    )
  
  def __call__(self):
    """
    Our main function.
    """
    self.write_mdr(filename="mdr.csv")
  
  
  def write_mdr(self, filename):
    """
    Write MDR to file system.
    """
    self.mdr.to_csv(
      path_or_buf=os.path.join(
        self.base_dir,
        filename
      ),
      sep=self.csv_separator,
      index = False
    )
    
