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
#     self.json_dict["Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator"] = "SELECT  \
# REPLACE(jsonb_path_query(r1.data_r1, '$.subject') ->> 'reference', 'Patient/', '') AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
# jsonb_path_query(r1.data_r1, '$.period') ->> 'start' AS fhir_start_date \
# FROM ( \
# SELECT DATA AS data_r1 \
# FROM resources \
# WHERE TYPE = 'Encounter' \
# ) r1;"
#     self.json_dict["Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator"] = "SELECT \
# REPLACE(jsonb_path_query(r1.data_r1, '$.subject') ->> 'reference', 'Patient/', '') AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\" \
# FROM ( \
# SELECT * FROM ( \
# SELECT \
# DATA AS data_r1, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"

#     self.json_dict["Person.Demographie.AdministrativesGeschlecht"] = "SELECT \
#     REPLACE(jsonb_path_query(r1.data_r1, '$.subject') ->> 'reference', 'Patient/', '') AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
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
#     self.json_dict["Person.Demographie.AdministrativesGeschlecht"] = "SELECT \
# r1.pid AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
# r2.jsonbdata2 ->> 'gender' AS \"Person.Demographie.AdministrativesGeschlecht\" \
# FROM ( SELECT * FROM ( \
# SELECT REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1, LATERAL ( \
# SELECT \
# DATA AS jsonbdata2 \
# FROM resources \
# WHERE TYPE = 'Patient' AND ( \
# (DATA ->> 'id') = r1.pid) \
# ) r2;"

    self.json_dict["Person.Demographie.AdministrativesGeschlecht"] = "SELECT \
r1.pid AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
r2.jsonbdata2 ->> 'gender' AS \"Person.Demographie.AdministrativesGeschlecht\" \
FROM ( SELECT * FROM ( \
SELECT REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1 \
LEFT JOIN ( \
SELECT \
fhir_id, \
DATA AS jsonbdata2 \
FROM resources \
WHERE TYPE = 'Patient') r2 \
ON r2.fhir_id = r1.pid;"


#     self.json_dict["Person.Demographie.Geburtsdatum"] = "SELECT \
# r1.pid AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
# r2.jsonbdata2 ->> 'birthDate' AS \"Person.Demographie.Geburtsdatum\" \
# FROM ( SELECT * FROM ( \
# SELECT REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1, LATERAL ( \
# SELECT \
# DATA AS jsonbdata2 \
# FROM resources \
# WHERE TYPE = 'Patient' AND ( \
# (DATA ->> 'id') = r1.pid) \
# ) r2;"

    self.json_dict["Person.Demographie.Geburtsdatum"] = "SELECT \
r1.pid AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
r2.jsonbdata2 ->> 'birthDate' AS \"Person.Demographie.Geburtsdatum\" \
FROM ( SELECT * FROM ( \
SELECT REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1 \
LEFT JOIN ( \
SELECT \
fhir_id, \
DATA AS jsonbdata2 \
FROM resources \
WHERE TYPE = 'Patient') r2 \
ON r2.fhir_id = r1.pid;"
    
    
    
#     self.json_dict["Fall.Versorgungsstellenkontakt.Aufnahmenummer"] = "SELECT  \
# REPLACE(jsonb_path_query(r1.data_r1, '$.subject') ->> 'reference', 'Patient/', '') AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
# jsonb_path_query(r1.data_r1, '$.period') ->> 'start' AS fhir_start_date, \
# r1.data_r1 ->> 'id' AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\" \
# FROM ( \
# SELECT DATA AS data_r1 \
# FROM resources \
# WHERE TYPE = 'Encounter' \
# ) r1;"
#     self.json_dict["Fall.Versorgungsstellenkontakt.Aufnahmenummer"] = "SELECT \
# r1.pid AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
# r1.jsonbdata ->> 'id' AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\" \
# FROM ( \
# SELECT * FROM ( \
# SELECT \
# DATA AS jsonbdata, \
# REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"


    self.json_dict["Fall.Versorgungsstellenkontakt.Aufnahmenummer"] = "SELECT \
r1.pid AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
r1.fhir_id AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\" \
FROM ( \
SELECT * FROM ( \
SELECT \
fhir_id, \
REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"

    self.json_dict["Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator"] = self.json_dict["Fall.Versorgungsstellenkontakt.Aufnahmenummer"]

#     self.json_dict["Fall.Versorgungsstellenkontakt.Beginndatum"] = "SELECT \
# r1.jsonbdata ->> 'id' AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
# to_timestamp(jsonb_path_query(r1.jsonbdata, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS \"Fall.Versorgungsstellenkontakt.Beginndatum\" \
# FROM ( \
# SELECT * FROM ( \
# SELECT \
# DATA AS jsonbdata, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"

    self.json_dict["Fall.Versorgungsstellenkontakt.Beginndatum"] = "SELECT \
fhir_id AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
fhir_start_date AS \"Fall.Versorgungsstellenkontakt.Beginndatum\" \
FROM ( \
SELECT * FROM ( \
SELECT \
fhir_id, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"


#     self.json_dict["Fall.Versorgungsstellenkontakt.Enddatum"] = "SELECT \
# r1.jsonbdata ->> 'id' AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
# to_timestamp(jsonb_path_query(r1.jsonbdata, '$.period') ->> 'end', 'YYYY-MM-DDTHH:MI:SS') AS \"Fall.Versorgungsstellenkontakt.Enddatum\" \
# FROM ( \
# SELECT * FROM ( \
# SELECT \
# DATA AS jsonbdata, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"

    self.json_dict["Fall.Versorgungsstellenkontakt.Enddatum"] = "SELECT \
fhir_id AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
to_timestamp(jsonb_path_query(r1.jsonbdata, '$.period') ->> 'end', 'YYYY-MM-DDTHH:MI:SS') AS \"Fall.Versorgungsstellenkontakt.Enddatum\" \
FROM ( \
SELECT * FROM ( \
SELECT \
fhir_id, \
DATA AS jsonbdata, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"


#     self.json_dict["Person.Demographie.Adresse.Strassenanschrift.PLZ"] = "SELECT \
# r1.pid AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
# jsonb_array_elements(jsonb_path_query(r2.jsonbdata2, '$.address')) ->> 'postalCode' AS \"Person.Demographie.Adresse.Strassenanschrift.PLZ\" \
# FROM ( SELECT * FROM ( \
# SELECT \
# REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1, LATERAL ( \
# SELECT \
# DATA AS jsonbdata2 \
# FROM resources \
# WHERE TYPE = 'Patient' AND ( \
# (DATA ->> 'id') = r1.pid) \
# ) r2;"

    self.json_dict["Person.Demographie.Adresse.Strassenanschrift.PLZ"] = "SELECT \
r1.pid AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
jsonb_array_elements(jsonb_path_query(r2.jsonbdata2, '$.address')) ->> 'postalCode' AS \"Person.Demographie.Adresse.Strassenanschrift.PLZ\" \
FROM ( SELECT * FROM ( \
SELECT \
REPLACE(jsonb_path_query(DATA, '$.subject') ->> 'reference', 'Patient/', '') AS pid, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1 \
LEFT JOIN ( \
SELECT \
fhir_id, \
DATA AS jsonbdata2 \
FROM resources \
WHERE TYPE = 'Patient') r2 \
ON r2.fhir_id = r1.pid;"

#     self.json_dict["Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode"] = "SELECT \
# r1.jsonbdata ->> 'id' AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
# jsonb_array_elements(jsonb_path_query(r2.jsonbdata2, '$.code.coding')) ->> 'code' AS \"Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode \" \
# FROM ( SELECT * FROM ( \
# SELECT \
# DATA AS jsonbdata, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1, LATERAL ( \
# SELECT \
# DATA AS jsonbdata2 \
# FROM resources \
# WHERE TYPE = 'Condition' AND ( \
# REPLACE(DATA -> 'encounter' ->> 'reference', 'Encounter/', '') = (r1.jsonbdata ->> 'id') \
# )) r2;"

    self.json_dict["Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode"] = "SELECT \
r1.fhir_id AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
jsonb_array_elements(jsonb_path_query(r2.jsonbdata2, '$.code.coding')) ->> 'code' AS \"Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode\" \
FROM ( SELECT * FROM ( \
SELECT \
fhir_id, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1 \
LEFT JOIN ( \
SELECT \
REPLACE(DATA -> 'encounter' ->> 'reference', 'Encounter/', '') AS eid, \
DATA AS jsonbdata2 \
FROM resources \
WHERE TYPE = 'Condition') r2 \
ON r2.eid = r1.fhir_id;"


#     self.json_dict["Prozedur.OPSProzedurKodiert.VollstaendigerProzedurenkode"] = "SELECT \
# r1.jsonbdata ->> 'id' AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
# jsonb_array_elements(jsonb_path_query(r2.jsonbdata2, '$.code.coding')) ->> 'code' AS \"Prozedur.OPSProzedurKodiert.VollstaendigerProzedurenkode\" \
# FROM ( SELECT * FROM ( \
# SELECT \
# DATA AS jsonbdata, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1, LATERAL ( \
# SELECT \
# DATA AS jsonbdata2 \
# FROM resources \
# WHERE TYPE = 'Procedure' AND ( \
# REPLACE(DATA -> 'encounter' ->> 'reference', 'Encounter/', '') = (r1.jsonbdata ->> 'id') \
# )) r2;"

    self.json_dict["Prozedur.OPSProzedurKodiert.VollstaendigerProzedurenkode"] = "SELECT \
r1.fhir_id AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
jsonb_array_elements(jsonb_path_query(r2.jsonbdata2, '$.code.coding')) ->> 'code' AS \"Prozedur.OPSProzedurKodiert.VollstaendigerProzedurenkode\" \
FROM ( SELECT * FROM ( \
SELECT \
fhir_id, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1 \
LEFT JOIN ( \
SELECT \
REPLACE(DATA -> 'encounter' ->> 'reference', 'Encounter/', '') AS eid, \
DATA AS jsonbdata2 \
FROM resources \
WHERE TYPE = 'Procedure') r2 \
ON r2.eid = r1.fhir_id;"

#     self.json_dict["Fall.Abteilungskontakt.Fachabteilungsschluessel"] = "SELECT \
# r1.jsonbdata ->> 'id' AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
# r1.code AS \"Fall.Abteilungskontakt.Fachabteilungsschluessel\" \
# FROM ( \
# SELECT jsonbdata, service_type ->> 'code' AS code, service_type ->> 'system' AS cd_system FROM ( \
# SELECT \
# DATA AS jsonbdata, \
# jsonb_array_elements(jsonb_path_query(DATA, '$.serviceType.coding')) AS service_type, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1 \
# WHERE r1.cd_system = 'https://www.medizininformatik-initiative.de/fhir/core/modul-fall/CodeSystem/Fachabteilungsschluessel';"

    self.json_dict["Fall.Abteilungskontakt.Fachabteilungsschluessel"] = "SELECT \
r1.fhir_id AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
r1.code AS \"Fall.Abteilungskontakt.Fachabteilungsschluessel\" \
FROM ( \
SELECT fhir_id, code, cd_system, fhir_profile FROM ( \
SELECT \
fhir_id, \
jsonb_array_elements(jsonb_path_query(DATA, '$.serviceType.coding')) ->> 'code' AS code, \
jsonb_array_elements(jsonb_path_query(DATA, '$.serviceType.coding')) ->> 'system' AS cd_system, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1 \
WHERE r1.cd_system = 'https://www.medizininformatik-initiative.de/fhir/core/modul-fall/CodeSystem/Fachabteilungsschluessel';"
    

#     self.json_dict["Fall.Einrichtungskontakt.Entlassungsgrund"] = "SELECT \
# r1.jsonbdata ->> 'id' AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",  \
# jsonb_array_elements(jsonb_path_query(r1.jsonbdata, '$.hospitalization')) ->> 'dischargeDisposition' AS \"Fall.Einrichtungskontakt.Entlassungsgrund\" \
# FROM ( \
# SELECT * FROM ( \
# SELECT \
# DATA AS jsonbdata, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"

    self.json_dict["Fall.Einrichtungskontakt.Entlassungsgrund"] = "SELECT \
r1.fhir_id AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
jsonb_array_elements(jsonb_path_query(r1.jsonbdata, '$.hospitalization.dischargeDisposition.coding.entlassungsgrund')) ->> 'code' AS \"Fall.Einrichtungskontakt.Entlassungsgrund\" \
FROM ( \
SELECT * FROM ( \
SELECT \
fhir_id, \
DATA AS jsonbdata, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"


#     self.json_dict["Fall.Einrichtungskontakt.Aufnahmeanlass"] = "SELECT \
# r1.jsonbdata ->> 'id' AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
# jsonb_array_elements(jsonb_path_query(r1.jsonbdata, '$.hospitalization')) ->> 'admitSource' AS \"Fall.Einrichtungskontakt.Aufnahmeanlass\" \
# FROM ( \
# SELECT * FROM ( \
# SELECT \
# DATA AS jsonbdata, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"

    self.json_dict["Fall.Einrichtungskontakt.Aufnahmeanlass"] = "SELECT \
r1.fhir_id AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
jsonb_array_elements(jsonb_path_query(r1.jsonbdata, '$.hospitalization.admitSource.coding.aufnahmeanlass')) ->> 'code' AS \"Fall.Einrichtungskontakt.Aufnahmeanlass\" \
FROM ( \
SELECT * FROM ( \
SELECT \
fhir_id, \
DATA AS jsonbdata, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"

#     self.json_dict["Fall.Einrichtungskontakt.Aufnahmegrund"] = "SELECT \
# r1.jsonbdata ->> 'id' AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
# r1.jsonbdata ->> 'reasonCode' AS \"Fall.Einrichtungskontakt.Aufnahmegrund\" \
# FROM ( \
# SELECT * FROM ( \
# SELECT \
# DATA AS jsonbdata, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"


    self.json_dict["Fall.Einrichtungskontakt.Aufnahmegrund"] = "SELECT \
r1.fhir_id AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
jsonb_array_elements(jsonb_path_query(r1.jsonbdata, '$.reasonCode.coding.aufnahmegrund')) ->> 'code' AS \"Fall.Einrichtungskontakt.Aufnahmegrund\" \
FROM ( \
SELECT * FROM ( \
SELECT \
fhir_id, \
DATA AS jsonbdata, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"

# 
#     self.json_dict["Laborbefund.Laboruntersuchung.Code"] = "SELECT \
# r1.jsonbdata ->> 'id' AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
# r2.code AS \"Laborbefund.Laboruntersuchung.Code\" \
# FROM ( SELECT * FROM ( \
# SELECT \
# DATA AS jsonbdata, \
# to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date \
# FROM resources \
# WHERE TYPE = 'Encounter') AS r_intermediate) r1, LATERAL ( \
# SELECT cd_system ->> 'code' AS code FROM ( \
# SELECT \
# DATA AS jsonbdata2, \
# jsonb_array_elements(jsonb_path_query(DATA, '$.code.coding')) AS cd_system, \
# jsonb_array_elements(jsonb_path_query(DATA, '$.category.coding')) AS cd_category \
# FROM resources \
# WHERE TYPE = 'Observation' AND ( \
# REPLACE(DATA -> 'encounter' ->> 'reference', 'Encounter/', '') = (r1.jsonbdata ->> 'id') \
# )) AS r3 \
# WHERE r3.cd_system ->> 'system' = 'http://loinc.org' AND \
# r3.cd_category ->> 'code' = '26436-6' \
# ) r2;"
# LOINC 26436-6 = Laboratory studies (set)


    self.json_dict["Laborbefund.Laboruntersuchung.Code"] = "SELECT \
r1.fhir_id AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
r2.cd_system ->> 'code' AS \"Laborbefund.Laboruntersuchung.Code\" \
FROM ( SELECT * FROM ( \
SELECT \
fhir_id, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1 \
LEFT JOIN ( \
SELECT \
REPLACE(jsonbdata2 -> 'encounter' ->> 'reference', 'Encounter/', '') AS eid, \
cd_system FROM ( \
SELECT \
DATA AS jsonbdata2, \
jsonb_array_elements(jsonb_path_query(DATA, '$.code.coding')) AS cd_system, \
jsonb_array_elements(jsonb_path_query(DATA, '$.category.coding')) AS cd_category \
FROM resources \
WHERE TYPE = 'Observation') r3 \
WHERE r3.cd_system ->> 'system' = 'http://loinc.org' AND \
r3.cd_category ->> 'code' = '26436-6' \
) r2 ON \
r2.eid = r1.fhir_id;"


    self.json_dict["Fall.Versorgungsstellenkontakt.KontaktKlasse"] = "SELECT \
r1.fhir_id AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
r1.class_code AS \"Fall.Versorgungsstellenkontakt.KontaktKlasse\" \
FROM ( \
SELECT * FROM ( \
SELECT \
fhir_id, \
jsonb_path_query(DATA, '$.class') ->> 'code' AS class_code, \
to_timestamp(jsonb_path_query(DATA, '$.period') ->> 'start', 'YYYY-MM-DDTHH:MI:SS') AS fhir_start_date, \
jsonb_array_elements_text(jsonb_path_query(DATA, '$.meta.profile')) AS fhir_profile \
FROM resources \
WHERE TYPE = 'Encounter') AS r_intermediate ) r1;"



if __name__ == "__main__":
  csql = CreateSQL()
  csql()
