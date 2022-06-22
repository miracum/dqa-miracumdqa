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
    # TODO: https://gitlab.miracum.org/miracum/etl/batch/fhir-to-i2b2/-/blob/master/sql/i2b2-FHIR-Trigger.sql#L929
    # Fall|Versorgungsfallklasse
    # 
#     self.json_dict["Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator"] = "SELECT \
# 	DISTINCT patient_num AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\" \
# FROM \
# 	visit_dimension;"
    
#     self.json_dict["Person.Demographie.AdministrativesGeschlecht"] = "SELECT \
# 	mn.patient_num AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
# 	jn.sex_cd AS \"Person.Demographie.AdministrativesGeschlecht\" \
# FROM \
# 	visit_dimension AS mn \
# JOIN \
# 	patient_dimension AS jn \
# ON \
# 	mn.patient_num = jn.patient_num;"

    # https://gitlab.miracum.org/miracum/etl/batch/fhir-to-i2b2/-/blob/master/sql/i2b2-FHIR-Trigger.sql#L798
    
#     self.json_dict["Person.Demographie.AdministrativesGeschlecht"] = "SELECT \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
# concept_cd AS \"Person.Demographie.AdministrativesGeschlecht\" \
# FROM observation_fact \
# WHERE concept_cd LIKE 'Dem|Sex:%' AND \
# modifier_cd = '@';"
    self.json_dict["Person.Demographie.AdministrativesGeschlecht"] = "SELECT \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
r2.concept_cd AS \"Person.Demographie.AdministrativesGeschlecht\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1 \
LEFT JOIN ( \
SELECT \
encounter_num, \
concept_cd \
FROM observation_fact \
WHERE concept_cd LIKE 'Dem|Sex:%' AND \
modifier_cd = '@' ) r2 \
ON r1.encounter_num = r2.encounter_num;"
    
#     self.json_dict["Person.Demographie.Geburtsdatum"] = "SELECT \
# mn.patient_num AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
# jn.birth_date::date AS \"Person.Demographie.Geburtsdatum\" \
# FROM visit_dimension AS mn \
# JOIN patient_dimension AS jn ON \
# mn.patient_num = jn.patient_num;"

    self.json_dict["Person.Demographie.Geburtsdatum"] = "SELECT \
r1.patient_num AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
r2.birth_date::date AS \"Person.Demographie.Geburtsdatum\" \
FROM ( \
SELECT * FROM ( \
SELECT \
patient_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1 \
LEFT JOIN ( \
SELECT \
patient_num, \
birth_date \
FROM patient_dimension ) r2 \
ON r1.patient_num = r2.patient_num;"
    
#     self.json_dict["Person.Demographie.Adresse.Strassenanschrift.PLZ"] = "SELECT \
# mn.patient_num AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
# jn.zip_cd AS \"Person.Demographie.Adresse.Strassenanschrift.PLZ\" \
# FROM visit_dimension AS mn \
# JOIN patient_dimension AS jn ON \
# mn.patient_num = jn.patient_num;"

    self.json_dict["Person.Demographie.Adresse.Strassenanschrift.PLZ"] = "SELECT \
r1.patient_num AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
r2.zip_cd AS \"Person.Demographie.Adresse.Strassenanschrift.PLZ\" \
FROM ( \
SELECT * FROM ( \
SELECT \
patient_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1 \
LEFT JOIN ( \
SELECT \
patient_num, \
zip_cd \
FROM patient_dimension ) r2 \
ON r1.patient_num = r2.patient_num;"
    
#     self.json_dict["Fall.Versorgungsstellenkontakt.Aufnahmenummer"] = "SELECT \
# patient_num AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\" \
# FROM visit_dimension;"

    self.json_dict["Fall.Versorgungsstellenkontakt.Aufnahmenummer"] = "SELECT \
r1.patient_num AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
patient_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1;"
	
    self.json_dict["Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator"] = self.json_dict["Fall.Versorgungsstellenkontakt.Aufnahmenummer"]
    
#     self.json_dict["Fall.Versorgungsstellenkontakt.Beginndatum"] = "SELECT \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
# start_date AS \"Fall.Versorgungsstellenkontakt.Beginndatum\" \
# FROM visit_dimension;"

    self.json_dict["Fall.Versorgungsstellenkontakt.Beginndatum"] = "SELECT \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
r1.i2b2_start_date AS \"Fall.Versorgungsstellenkontakt.Beginndatum\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1;"
    
#     self.json_dict["Fall.Versorgungsstellenkontakt.Enddatum"] = "SELECT \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
# end_date AS \"Fall.Versorgungsstellenkontakt.Enddatum\" \
# FROM visit_dimension;"

    self.json_dict["Fall.Versorgungsstellenkontakt.Enddatum"] = "SELECT \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\", \
r1.end_date AS \"Fall.Versorgungsstellenkontakt.Enddatum\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
start_date AS i2b2_start_date, \
end_date \
FROM \
visit_dimension ) AS r_intermediate) r1;"
    
#     self.json_dict["Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode"] = "SELECT \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
# concept_cd AS \"Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode\" \
# FROM observation_fact \
# WHERE concept_cd LIKE 'ICD10:%' AND \
# modifier_cd = '@';"

    self.json_dict["Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode"] = "SELECT \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
r2.concept_cd AS \"Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1 \
LEFT JOIN ( \
SELECT \
encounter_num, \
concept_cd \
FROM observation_fact \
WHERE concept_cd LIKE 'ICD10:%' AND \
modifier_cd = '@' ) r2 \
ON r1.encounter_num = r2.encounter_num;"
    
#     self.json_dict["Prozedur.OPSProzedurKodiert.VollstaendigerProzedurenkode"] = "SELECT \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
# concept_cd AS \"Prozedur.OPSProzedurKodiert.VollstaendigerProzedurenkode\" \
# FROM observation_fact \
# WHERE concept_cd LIKE 'OPS:%' AND \
# modifier_cd = '@';"

    self.json_dict["Prozedur.OPSProzedurKodiert.VollstaendigerProzedurenkode"] = "SELECT \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
r2.concept_cd AS \"Prozedur.OPSProzedurKodiert.VollstaendigerProzedurenkode\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1 \
LEFT JOIN ( \
SELECT \
encounter_num, \
concept_cd \
FROM observation_fact \
WHERE concept_cd LIKE 'OPS:%' AND \
modifier_cd = '@' ) r2 \
ON r1.encounter_num = r2.encounter_num;"
    
#     self.json_dict["Fall.Abteilungskontakt.Fachabteilungsschluessel"] = "SELECT \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
# concept_cd AS \"Fall.Abteilungskontakt.Fachabteilungsschluessel\" \
# FROM observation_fact \
# WHERE concept_cd LIKE 'Fall|Fachabteilungsschluessel:%' AND \
# modifier_cd = '@';"

    self.json_dict["Fall.Abteilungskontakt.Fachabteilungsschluessel"] = "SELECT \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
r2.concept_cd AS \"Fall.Abteilungskontakt.Fachabteilungsschluessel\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1 \
LEFT JOIN ( \
SELECT \
encounter_num, \
concept_cd \
FROM observation_fact \
WHERE concept_cd LIKE 'Fall|Fachabteilungsschluessel:%' AND \
modifier_cd = '@' ) r2 \
ON r1.encounter_num = r2.encounter_num;"
    
#     self.json_dict["Fall.Einrichtungskontakt.Entlassungsgrund"] = "SELECT \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
# concept_cd AS \"Fall.Einrichtungskontakt.Entlassungsgrund\" \
# FROM observation_fact \
# WHERE concept_cd LIKE 'Fall|Entlassungsgrund:%' AND \
# modifier_cd = '@';"

    self.json_dict["Fall.Einrichtungskontakt.Entlassungsgrund"] = "SELECT \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
r2.concept_cd AS \"Fall.Einrichtungskontakt.Entlassungsgrund\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1 \
LEFT JOIN ( \
SELECT \
encounter_num, \
concept_cd \
FROM observation_fact \
WHERE concept_cd LIKE 'Fall|Entlassungsgrund:%' AND \
modifier_cd = '@' ) r2 \
ON r1.encounter_num = r2.encounter_num;"
    
#     self.json_dict["Fall.Einrichtungskontakt.Aufnahmeanlass"] = "SELECT \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
# concept_cd AS \"Fall.Einrichtungskontakt.Aufnahmeanlass\" \
# FROM observation_fact \
# WHERE concept_cd LIKE 'Fall|Aufnahmeanlass:%' AND \
# modifier_cd = '@';"

    self.json_dict["Fall.Einrichtungskontakt.Aufnahmeanlass"] = "SELECT \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
r2.concept_cd AS \"Fall.Einrichtungskontakt.Aufnahmeanlass\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1 \
LEFT JOIN ( \
SELECT \
encounter_num, \
concept_cd \
FROM observation_fact \
WHERE concept_cd LIKE 'Fall|Aufnahmeanlass:%' AND \
modifier_cd = '@' ) r2 \
ON r1.encounter_num = r2.encounter_num;"
    
#     self.json_dict["Fall.Einrichtungskontakt.Aufnahmegrund"] = "SELECT \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
# concept_cd AS \"Fall.Einrichtungskontakt.Aufnahmegrund\" \
# FROM observation_fact \
# WHERE concept_cd LIKE 'Fall|Aufnahmegrund:%' AND \
# modifier_cd = '@';"

    self.json_dict["Fall.Einrichtungskontakt.Aufnahmegrund"] = "SELECT \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
r2.concept_cd AS \"Fall.Einrichtungskontakt.Aufnahmegrund\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1 \
LEFT JOIN ( \
SELECT \
encounter_num, \
concept_cd \
FROM observation_fact \
WHERE concept_cd LIKE 'Fall|Aufnahmegrund:%' AND \
modifier_cd = '@' ) r2 \
ON r1.encounter_num = r2.encounter_num;"

#     self.json_dict["Laborbefund.Laboruntersuchung.Code"] = "SELECT \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
# concept_cd AS \"Laborbefund.Laboruntersuchung.Code\" \
# FROM observation_fact \
# WHERE concept_cd LIKE 'LOINC:%' AND \
# modifier_cd = 'LOINC:26436-6';" # LOINC 26436-6 = Laboratory studies (set)

    self.json_dict["Laborbefund.Laboruntersuchung.Code"] = "SELECT \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
r2.concept_cd AS \"Laborbefund.Laboruntersuchung.Code\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1 \
LEFT JOIN ( \
SELECT \
encounter_num, \
concept_cd \
FROM observation_fact \
WHERE concept_cd LIKE 'LOINC:%' AND \
modifier_cd = 'LOINC:26436-6' ) r2 \
ON r1.encounter_num = r2.encounter_num;"

#     self.json_dict["Fall.Versorgungsstellenkontakt.KontaktKlasse"] = "SELECT \
# encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
# concept_cd AS \"Fall.Versorgungsstellenkontakt.KontaktKlasse\" \
# FROM observation_fact \
# WHERE concept_cd LIKE 'Fall|Versorgungsfallklasse:%' AND \
# modifier_cd = '@';"

    self.json_dict["Fall.Versorgungsstellenkontakt.KontaktKlasse"] = "SELECT \
r1.encounter_num AS \"Fall.Versorgungsstellenkontakt.Aufnahmenummer\",\
r2.concept_cd AS \"Fall.Versorgungsstellenkontakt.KontaktKlasse\" \
FROM ( \
SELECT * FROM ( \
SELECT \
encounter_num, \
start_date AS i2b2_start_date \
FROM \
visit_dimension ) AS r_intermediate) r1 \
LEFT JOIN ( \
SELECT \
encounter_num, \
concept_cd \
FROM observation_fact \
WHERE concept_cd LIKE 'Fall|Versorgungsfallklasse:%' AND \
modifier_cd = '@' ) r2 \
ON r1.encounter_num = r2.encounter_num;"


if __name__ == "__main__":
  csql = CreateSQL()
  csql()
