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
#     self.json_dict["Person.Patient.Patienten-Identifikator.Patienten-Identifikator"] = "SELECT  \
# REPLACE(jsonb_path_query(r1.data_r1, '$.subject') ->> 'reference', 'Patient/', '') AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\", \
# jsonb_path_query(r1.data_r1, '$.period') ->> 'start' AS fhir_start_date \
# FROM ( \
# SELECT DATA AS data_r1 \
# FROM resources \
# WHERE TYPE = 'Encounter' \
# ) r1;"
    self.json_dict["Person.Patient.Patienten-Identifikator.Patienten-Identifikator"] = "SELECT \
REPLACE(jsonb_path_query(r1.data_r1, '$.subject') ->> 'reference', 'Patient/', '') AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\" \
FROM ( \
SELECT * FROM ( \
SELECT \
DATA AS data_r1, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate \
WHERE r_intermediate.fhir_start_date >= '2020-01-01' AND r_intermediate.fhir_start_date < '2021-01-01' \
) r1;"

#     self.json_dict["Person.Demographie.AdministrativesGeschlecht"] = "SELECT \
#     REPLACE(jsonb_path_query(r1.data_r1, '$.subject') ->> 'reference', 'Patient/', '') AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\", \
# jsonb_path_query(r1.data_r1, '$.period') ->> 'start' AS fhir_start_date \
# , r2.data_r2 ->> 'gender' AS \"Person.Demographie.AdministrativesGeschlecht\" \
# FROM ( \
# SELECT DATA AS data_r1 \
# FROM resources \
# WHERE TYPE = 'Encounter' \
# ) r1 \
# JOIN LATERAL ( \
# SELECT \
# DATA AS data_r2 \
# FROM resources \
# WHERE TYPE = 'Patient' \
# ) r2 \
# ON REPLACE(r1.data_r1 -> 'subject' ->> 'reference', 'Patient/', '') = (r2.data_r2 ->> 'id');"
    self.json_dict["Person.Demographie.AdministrativesGeschlecht"] = "SELECT \
    r1.pid AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\", \
    r2.gender AS \"Person.Demographie.AdministrativesGeschlecht\" \
FROM ( \
SELECT * FROM ( \
SELECT \
REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate \
WHERE r_intermediate.fhir_start_date >= '2020-01-01' AND r_intermediate.fhir_start_date < '2021-01-01' \
) r1, LATERAL ( \
SELECT \
DATA ->> 'gender' AS gender \
FROM resources r_intermediate \
WHERE TYPE = 'Patient' AND ( \
(DATA ->> 'id' = r1.pid) \
)) r2;"


    self.json_dict["Person.Demographie.Geburtsdatum"] = "SELECT \
    r1.pid AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\", \
    r2.birthdate AS \"Person.Demographie.Geburtsdatum\" \
FROM ( \
SELECT * FROM ( \
SELECT \
REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate \
WHERE r_intermediate.fhir_start_date >= '2020-01-01' AND r_intermediate.fhir_start_date < '2021-01-01' \
) r1, LATERAL ( \
SELECT \
DATA ->> 'birthDate' AS birthdate \
FROM resources r_intermediate \
WHERE TYPE = 'Patient' AND ( \
(DATA ->> 'id' = r1.pid) \
)) r2;"


#     self.json_dict["Fall.Einrichtungskontakt.Aufnahmenummer"] = "SELECT  \
# REPLACE(jsonb_path_query(r1.data_r1, '$.subject') ->> 'reference', 'Patient/', '') AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\", \
# jsonb_path_query(r1.data_r1, '$.period') ->> 'start' AS fhir_start_date, \
# r1.data_r1 ->> 'id' AS \"Fall.Einrichtungskontakt.Aufnahmenummer\" \
# FROM ( \
# SELECT DATA AS data_r1 \
# FROM resources \
# WHERE TYPE = 'Encounter' \
# ) r1;"
    self.json_dict["Fall.Einrichtungskontakt.Aufnahmenummer"] = "SELECT \
r1.pid AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\", \
r1.jsonbdata ->> 'id' AS \"Fall.Einrichtungskontakt.Aufnahmenummer\" \
FROM ( \
SELECT * FROM ( \
SELECT \
DATA AS jsonbdata, \
REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate \
WHERE r_intermediate.fhir_start_date >= '2020-01-01' AND r_intermediate.fhir_start_date < '2021-01-01' \
) r1;"

    self.json_dict["Fall.Einrichtungskontakt.Beginndatum"] = "SELECT \
r1.pid AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\", \
to_timestamp(jsonb_path_query(r1.jsonbdata, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS \"Fall.Einrichtungskontakt.Beginndatum\" \
FROM ( \
SELECT * FROM ( \
SELECT \
DATA AS jsonbdata, \
REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate \
WHERE r_intermediate.fhir_start_date >= '2020-01-01' AND r_intermediate.fhir_start_date < '2021-01-01' \
) r1;"


    self.json_dict["Person.Demographie.Adresse.PLZ"] = "SELECT \
    r1.pid AS \"Person.Patient.Patienten-Identifikator.Patienten-Identifikator\", \
    r2.plz AS \"Person.Demographie.Adresse.PLZ\" \
FROM ( \
SELECT * FROM ( \
SELECT \
REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate \
WHERE r_intermediate.fhir_start_date >= '2020-01-01' AND r_intermediate.fhir_start_date < '2021-01-01' \
) r1, LATERAL ( \
SELECT \
jsonb_array_elements(jsonb_path_query(DATA, '$.address')) ->> 'postalCode' AS plz \
FROM resources r_intermediate \
WHERE TYPE = 'Patient' AND ( \
(DATA ->> 'id' = r1.pid) \
)) r2;"

if __name__ == "__main__":
  csql = CreateSQL()
  csql()
