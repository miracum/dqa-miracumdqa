import json
import os



class CreateSQL():
  
  def __init__(self):
    """
    Instantiate some basics.
    """
    self.base_dir = os.path.abspath(os.path.dirname(__file__))
    json_file = "SQL_fhir_gw.JSON"
    
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
    self.json_dict["Person.Patient.Patienten-Identifikator.Patienten-Identifikator"] = "SELECT  \
REPLACE(jsonb_path_query(r1.data_r1, '$.subject') ->> 'reference', 'Patient/', '') AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\", \
jsonb_path_query(r1.data_r1, '$.period') ->> 'start' AS fhir_start_date, \
FROM ( \
SELECT DATA AS data_r1 \
FROM resources \
WHERE TYPE = 'Encounter' \
) r1;"

    self.json_dict["Person.Demographie.AdministrativesGeschlecht"] = "SELECT \
    REPLACE(jsonb_path_query(r1.data_r1, '$.subject') ->> 'reference', 'Patient/', '') AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\", \
jsonb_path_query(r1.data_r1, '$.period') ->> 'start' AS fhir_start_date \
, r2.data_r2 ->> 'gender' AS \"Person.Demographie.AdministrativesGeschlecht\" \
FROM ( \
SELECT DATA AS data_r1 \
FROM resources \
WHERE TYPE = 'Encounter' \
) r1 \
JOIN LATERAL ( \
SELECT \
DATA AS data_r2 \
FROM resources \
WHERE TYPE = 'Patient' \
) r2 \
ON REPLACE(r1.data_r1 -> 'subject' ->> 'reference', 'Patient/', '') = (r2.data_r2 ->> 'id');"


    self.json_dict["Fall.Einrichtungskontakt.Aufnahmenummer"] = "SELECT  \
REPLACE(jsonb_path_query(r1.data_r1, '$.subject') ->> 'reference', 'Patient/', '') AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\", \
jsonb_path_query(r1.data_r1, '$.period') ->> 'start' AS fhir_start_date, \
r1.data_r1 ->> 'id' AS \"Fall.Einrichtungskontakt.Aufnahmenummer\" \
FROM ( \
SELECT DATA AS data_r1 \
FROM resources \
WHERE TYPE = 'Encounter' \
) r1;"

if __name__ == "__main__":
  csql = CreateSQL()
  csql()
