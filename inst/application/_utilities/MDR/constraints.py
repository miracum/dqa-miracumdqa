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

import json
import os
import pandas as pd

from python_mdr_handling import MDRHandling



class WriteConstraints(MDRHandling):
  
  def __init__(self, **kwargs):
    """
    Instantiate some basics.
    """
    super().__init__(**kwargs)
    
  
  def __call__(self):
    """
    Our main function.
    """
    self.add_constraints()
    
    self.write_mdr(filename="mdr.csv")
  
  
  def add_constraints(self):
    
    self.mdr.loc[
      (self.mdr.designation == "AdministrativesGeschlecht") &
      (self.mdr.source_system_name == "i2b2") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"value_set": ["Dem|Sex:male", "Dem|Sex:female", "Dem|Sex:unknown"]}
      )
    
    self.mdr.loc[
      (self.mdr.designation == "AdministrativesGeschlecht") &
      (self.mdr.source_system_name == "fhir_gw") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"value_set": ["male", "female", "unknown"]}
      )
    
    self.mdr.loc[
      (self.mdr.designation == "AdministrativesGeschlecht") &
      (self.mdr.source_system_name == "omop") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"value_set": ["male", "female", "unknown"]}
      )
      
    
    
    self.mdr.loc[
      (self.mdr.designation == "VollstaendigerDiagnosekode") &
      (self.mdr.source_system_name == "i2b2") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"regex": "^(ICD10\\:)([[:upper:]]){1}([[:digit:]]{1,2})((\\.)([[:digit:]]{1,2}))?(\\+|\\*|\\!)?$"}
      )
      
    self.mdr.loc[
      (self.mdr.designation == "VollstaendigerDiagnosekode") &
      (self.mdr.source_system_name == "fhir_gw") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"regex": "^([[:upper:]]){1}([[:digit:]]{1,2})((\\.)([[:digit:]]{1,2}))?(\\+|\\*|\\!)?$"}
      )
      
    self.mdr.loc[
      (self.mdr.designation == "VollstaendigerDiagnosekode") &
      (self.mdr.source_system_name == "omop") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"regex": "^([[:upper:]]){1}([[:digit:]]{1,2})((\\.)([[:digit:]]{1,2}))?(\\+|\\*|\\!)?$"}
      )
      
    
    
    self.mdr.loc[
      (self.mdr.designation == "VollstaendigerProzedurenkode") &
      (self.mdr.source_system_name == "i2b2") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"regex": "^(OPS\\:)([[:digit:]]{1})(\\-)([[:digit:]]{2})([[:lower:]]{1}|([[:digit:]]{1}))((\\.)([[:alnum:]]){1,2})?$"}
      )
      
    self.mdr.loc[
      (self.mdr.designation == "VollstaendigerProzedurenkode") &
      (self.mdr.source_system_name == "fhir_gw") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"regex": "^([[:digit:]]{1})(\\-)?([[:digit:]]{2})([[:lower:]]{1}|([[:digit:]]{1}))((\\.)?([[:alnum:]]){1,2})?$"}
      )
      
    self.mdr.loc[
      (self.mdr.designation == "VollstaendigerProzedurenkode") &
      (self.mdr.source_system_name == "omop") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"regex": "^([[:digit:]]{1})(\\-)([[:digit:]]{2})([[:lower:]]{1}|([[:digit:]]{1}))((\\.)([[:alnum:]]){1,2})?$"}
      )
    
    self.mdr.loc[
      (self.mdr.designation == "KontaktKlasse") &
      (self.mdr.source_system_name == "i2b2") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"regex": "^(Fall|Versorgungsfallklasse\\:)ambulant|stationaer$"}
      )
    self.mdr.loc[
      (self.mdr.designation == "KontaktKlasse") &
      (self.mdr.source_system_name == "fhir_gw") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"regex": "^ambulant|stationaer$"}
      )
    

if __name__ == "__main__":
  wrcs = WriteConstraints(mdr_file="mdr.csv")
  wrcs()
