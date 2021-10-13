import json
import os



class CreateSQL():
  
  def __init__(self):
    """
    Instantiate some basics.
    """
    self.base_dir = os.path.abspath(os.path.dirname(__file__))
    json_file = "SQL_i2b2.JSON"
    
    self.json_path = os.path.join(
      self.base_dir,
      json_file
    )
    
    # create dictionary to store statements in:
    self.json_dict = {}
  
  def __call__(self):
    """
    Our main function.
    """
    self.create_dict()
  
    with open(self.json_path, "w") as outfile:
      json.dump(
        obj=self.json_dict,
        fp=outfile,
        indent=2
      )
    
  
  
  def create_dict(self):
    """
    Create dictionary to dump to JSON file here.
    
    TODO: add some logic to use mappings from MDR.CSV
    """
    self.json_dict["Person.Patient.Patienten-Identifikator.Patienten-Identifikator"] = "SELECT\
	DISTINCT patient_num AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\"\
FROM\
	i2b2miracum.patient_dimension;"
    

if __name__ == "__main__":
  csql = CreateSQL()
  csql()
