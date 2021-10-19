import os
import pandas as pd

class MDRHandling():
  
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
      sep=csv_separator,
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
      sep=";",
      index = False
    )
    
