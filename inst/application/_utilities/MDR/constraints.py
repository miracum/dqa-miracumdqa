import json
import os
import pandas as pd

from python_mdr_handling import MDRHandling



class WriteConstraints(MDRHandling):
  
  def __init__(self):
    """
    Instantiate some basics.
    """
    super().__init__()
    
  
  def __call__(self):
    """
    Our main function.
    """
    self.add_constraints()
    
    self.write_mdr(filename="mdr.csv")
  
  
  def add_constraints(self):
    
    self.mdr.loc[
      (self.mdr.designation == "Person.Demographie.AdministrativesGeschlecht") &
      (self.mdr.source_system_name == "i2b2") &
      (self.mdr.dqa_assessment == "1"),
      "constraints"] = json.dumps(
        {"value_set": "DEM|GESCHLECHT:m, DEM|GESCHLECHT:w, DEM|GESCHLECHT:x"}
      )
    
    

if __name__ == "__main__":
  wrcs = WriteConstraints()
  wrcs()
