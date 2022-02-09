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

#!/usr/bin/python





import json
import os
import pandas as pd

from python_mdr_handling import MDRHandling



class PrepareMDR(MDRHandling):
  
  def __init__(self, **kwargs):
    """
    Instantiate some basics.
    """
    super().__init__(**kwargs)
    
  
  def __call__(self):
    """
    Our main function.
    """
    self.prepare_mdr()
    
    self.write_mdr(filename="mdr_prepared.csv")
  
  
  def prepare_mdr(self):
    # define names to keep,
    keep_rows = {
      "AdministrativesGeschlecht": "Person.Demographie.AdministrativesGeschlecht",
      "Geburtsdatum": "Person.Demographie.Geburtsdatum",
      "PLZ": "Person.Demographie.Adresse.PLZ",
      "Patienten-Identifikator": "Person.Patient.Patienten-Identifikator.Patienten-Identifikator",
      "Aufnahmenummer": "Fall.Einrichtungskontakt.Aufnahmenummer",
      "Beginndatum": "Fall.Einrichtungskontakt.Beginndatum",
      "Enddatum": "Fall.Einrichtungskontakt.Enddatum",
      "VollstaendigerDiagnosekode": "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode"
    }
    
    # duplicate rows for databases
    db_names = ["i2b2", "fhir_gw"]
    
    # generate grid for every possible combination of designation, system_name and system_type
    pd_dat = [
      {
        "designation": x,
        "source_system_name": y,
        "source_system_type": z} for x in keep_rows.keys() for y in db_names for z in ["postgres"]
      ]
    
    merge_df = pd.DataFrame(
      data = pd_dat
    )
    
    # remove rows with missing definition
    self.mdr.dropna(subset = ["definition"], inplace = True)
    
    # remove duplicate values
    self.mdr.drop_duplicates(inplace=True)
    
    # drop columns that are being joined with merge_df
    self.mdr.drop(
      columns = ["source_system_name", "source_system_type"],
      inplace = True
    )
    
    self.mdr = self.mdr.merge(
      right = merge_df,
      how = "inner",
      on = "designation"
    )
    
    # set some default values
    self.mdr.dqa_assessment = "1"
    
    # replace designation
    self.mdr.replace({"designation": keep_rows}, inplace = True)
    
    # set keys and variable_name
    self.mdr.key = self.mdr.designation
    self.mdr.variable_name = self.mdr.designation
    

if __name__ == "__main__":
  prep = PrepareMDR(
    mdr_file="dehub_mdr_clean.csv-20220209_110106.csv",
    csv_separator="\t"
  )
  prep()
