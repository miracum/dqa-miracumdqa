import json
import os
import pandas as pd



class WriteConstraints():
  
  def __init__(self, csv_separator:str = ";"):
    """
    Instantiate some basics.
    """
    self.base_dir = os.path.abspath(os.path.dirname(__file__))
    mdr_file = "mdr.csv"
    
    self.mdr_path = os.path.join(
      self.base_dir,
      mdr_file
    )
    
    self.mdr = pd.read_csv(
      filepath_or_buffer=self.mdr_path,
      sep=csv_separator
    )
    
    print(self.mdr.head())
  
  def __call__(self):
    """
    Our main function.
    """
    pass
    
  
  
  def add_constraints(self):
    pass
    
    

if __name__ == "__main__":
  wrcs = WriteConstraints()
  wrcs()
