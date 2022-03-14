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
    json_file = "SQL_omop.JSON"
    
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
    """
    
    self.json_dict["Person.Demographie.AdministrativesGeschlecht"] = "SELECT \
mn.visit_occurrence_id AS \"Fall.Einrichtungskontakt.Aufnahmenummer\",\
jn.gender_source_value AS \"Person.Demographie.AdministrativesGeschlecht\" \
FROM cds_cdm.visit_occurrence AS mn \
JOIN cds_cdm.person AS jn ON \
mn.person_id = jn.person_id;"
    
    self.json_dict["Person.Demographie.Geburtsdatum"] = "SELECT \
mn.person_id AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
jn.year_of_birth AS \"Person.Demographie.Geburtsdatum\" \
FROM cds_cdm.visit_occurrence AS mn \
JOIN cds_cdm.person AS jn ON \
mn.person_id = jn.person_id;"
    
    self.json_dict["Person.Demographie.Adresse.Strassenanschrift.PLZ"] = "SELECT \
mn.person_id AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
jn.zip AS \"Person.Demographie.Adresse.Strassenanschrift.PLZ\" \
FROM cds_cdm.visit_occurrence AS mn \
JOIN ( \
  SELECT loc.zip \
  FROM cds_cdm.person AS per \
  JOIN cds_cdm.location AS loc ON \
  per.location_id = loc.location_id \
) AS jn ON \
mn.person_id = jn.person_id;"
    
    self.json_dict["Fall.Einrichtungskontakt.Aufnahmenummer"] = "SELECT \
person_id AS \"Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator\", \
visit_occurrence_id AS \"Fall.Einrichtungskontakt.Aufnahmenummer\" \
FROM cds_cdm.visit_occurrence;"
	
    self.json_dict["Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator"] = self.json_dict["Fall.Einrichtungskontakt.Aufnahmenummer"]
    
    self.json_dict["Fall.Einrichtungskontakt.Beginndatum"] = "SELECT \
b.visit_occurrence_id AS \"Fall.Einrichtungskontakt.Aufnahmenummer\", \
a.visit_start_date::date AS \"Fall.Einrichtungskontakt.Beginndatum\" \
FROM cds_cdm.visit_occurrence AS b \
LEFT OUTER JOIN ( \
SELECT visit_occurrence_id, visit_start_date \
FROM cds_cdm.visit_occurrence) AS a ON \
a.visit_occurrence_id = b.visit_occurrence_id;"
    
    self.json_dict["Fall.Einrichtungskontakt.Enddatum"] = "SELECT \
b.visit_occurrence_id AS \"Fall.Einrichtungskontakt.Aufnahmenummer\", \
a.visit_end_date::date AS \"Fall.Einrichtungskontakt.Enddatum\" \
FROM cds_cdm.visit_occurrence AS b \
LEFT OUTER JOIN ( \
SELECT visit_occurrence_id, visit_end_date \
FROM cds_cdm.visit_occurrence) AS a ON \
a.visit_occurrence_id = b.visit_occurrence_id;"
    
    self.json_dict["Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode"] = "SELECT \
b.visit_occurrence_id AS \"Fall.Einrichtungskontakt.Aufnahmenummer\",\
a.condition_source_value AS \"Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode\" \
FROM cds_cdm.visit_occurrence AS b \
LEFT OUTER JOIN ( \
SELECT visit_occurrence_id, condition_source_value \
FROM cds_cdm.condition_occurrence) AS a ON \
a.visit_occurrence_id = b.visit_occurrence_id"

if __name__ == "__main__":
  csql = CreateSQL()
  csql()
