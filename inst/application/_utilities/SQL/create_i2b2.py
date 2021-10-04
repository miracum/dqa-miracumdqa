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
    self.json_dict["dt.patient"] = "SELECT\n\tpatient_num\tAS\t\"patient_identifier_value\"\nFROM\n\ti2b2miracum.patient_dimension\nORDER BY\n\tpatient_num;"
    self.json_dict["dt.gender"] = "SELECT\n\tconcept_cd\tAS\t\"encounter_subject_patient_gender\",\npatient_num\tAS\t\"encounter_subject_patient_identifier_value\"\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'DEM|GESCHLECHT%'\nORDER BY\n\tpatient_num;"
    self.json_dict["dt.zipcode"] = "SELECT\n\tpatient_num\tAS\t\"patient_identifier_value\",\nzip_cd\tAS\t\"patient_address_postalCode\"\nFROM\n\ti2b2miracum.patient_dimension\nORDER BY\n\tpatient_num;"
    self.json_dict["dt.birthdate"] = "SELECT\n\tbirth_date\tAS\t\"patient_birthDate\",\npatient_num\tAS\t\"patient_identifier_value\"\nFROM\n\ti2b2miracum.patient_dimension\nORDER BY\n\tpatient_num;"
    self.json_dict["dt.encounter"] = "SELECT\n\tencounter_num\tAS\t\"encounter_identifier_value\",\n\tpatient_num\tAS\t\"encounter_subject_patient_identifier_value\"\nFROM\n\ti2b2miracum.visit_dimension\nWHERE\n\tvisit_blob = 'True encounter'\nORDER BY\n\tencounter_num;"
    self.json_dict["dt.encounterstart"] = "SELECT\n\tb.encounter_num\tAS\t\"encounter_identifier_value\",\n\ta.start_date::date\tAS\t\"encounter_period_start\"\nFROM\n\ti2b2miracum.visit_dimension AS b\nLEFT OUTER JOIN (\nSELECT\n\tencounter_num, start_date\nFROM\n\ti2b2miracum.visit_dimension) AS a ON\n\ta.encounter_num = b.encounter_num\nWHERE\n\tb.visit_blob = 'True encounter'\nORDER BY\n\tb.encounter_num;"
    self.json_dict["dt.encounterend"] = "SELECT\n\tb.encounter_num\tAS\t\"encounter_identifier_value\",\n\ta.end_date::date\tAS\t\"encounter_period_end\"\nFROM\n\ti2b2miracum.visit_dimension AS b\nLEFT OUTER JOIN (\nSELECT\n\tencounter_num, end_date\nFROM\n\ti2b2miracum.visit_dimension) AS a ON\n\ta.encounter_num = b.encounter_num\nWHERE\n\tb.visit_blob = 'True encounter'\nORDER BY\n\tb.encounter_num;"
    self.json_dict["dt.ageindays"] = "SELECT\n\tb.encounter_num\tAS\t\"encounter_identifier_value\",\n\ta.nval_num\tAS\t\"encounter_subject_patient_age_days\"\nFROM\n\ti2b2miracum.visit_dimension AS b\nLEFT OUTER JOIN (\nSELECT\n\tencounter_num, nval_num\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'DEM|AUFNAHMEALTERTAGE%') AS a ON\n\ta.encounter_num = b.encounter_num\nWHERE\n\tb.visit_blob = 'True encounter'\nORDER BY\n\tb.encounter_num;"
    self.json_dict["dt.ageinyears"] = "SELECT\n\tb.encounter_num\tAS\t\"encounter_identifier_value\",\n\ta.nval_num\tAS\t\"encounter_subject_patient_age_years\"\nFROM\n\ti2b2miracum.visit_dimension AS b\nLEFT OUTER JOIN (\nSELECT\n\tencounter_num, nval_num\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'DEM|AUFNAHMEALTERJAHRE%') AS a ON\n\ta.encounter_num = b.encounter_num\nWHERE\n\tb.visit_blob = 'True encounter'\nORDER BY\n\tb.encounter_num;"
    self.json_dict["dt.admission"] = "SELECT\n\tb.encounter_num\tAS\t\"encounter_identifier_value\",\n\ta.concept_cd\tAS\t\"encounter_hospitalization_admitSource\"\nFROM\n\ti2b2miracum.visit_dimension AS b\nLEFT OUTER JOIN (\nSELECT\n\tencounter_num, concept_cd\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'FALL|AUFNAHMEANLASS%') AS a ON\n\ta.encounter_num = b.encounter_num\nWHERE\n\tb.visit_blob = 'True encounter'\nORDER BY\n\tb.encounter_num;"
    self.json_dict["dt.hospitalization"] = "SELECT\n\tb.encounter_num\tAS\t\"encounter_identifier_value\",\n\ta.concept_cd\tAS\t\"encounter_hospitalization_class\"\nFROM\n\ti2b2miracum.visit_dimension AS b\nLEFT OUTER JOIN (\nSELECT\n\tencounter_num, concept_cd\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'FALL|AUFNAHMEGRUND%') AS a ON\n\ta.encounter_num = b.encounter_num\nWHERE\n\tb.visit_blob = 'True encounter'\nORDER BY\n\tb.encounter_num;"
    self.json_dict["dt.discharge"] = "SELECT\n\tb.encounter_num\tAS\t\"encounter_identifier_value\",\n\ta.concept_cd\tAS\t\"encounter_hospitalization_dischargeDisposition\"\nFROM\n\ti2b2miracum.visit_dimension AS b\nLEFT OUTER JOIN (\nSELECT\n\tencounter_num, concept_cd\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'FALL|ENTLASSGRUND%') AS a ON\n\ta.encounter_num = b.encounter_num\nWHERE\n\tb.visit_blob = 'True encounter'\nORDER BY\n\tb.encounter_num;"
    self.json_dict["dt.ventilation"] = "SELECT\n\tb.encounter_num\tAS\t\"procedure_encounter_identifier_value\",\n\ta.nval_num\tAS\t\"observation_code_coding_code\"\nFROM\n\ti2b2miracum.visit_dimension AS b\nLEFT OUTER JOIN (\nSELECT\n\tencounter_num, nval_num\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'LOINC:74201-5') AS a ON\n\ta.encounter_num = b.encounter_num\nWHERE\n\tb.visit_blob = 'True encounter'\nORDER BY\n\tb.encounter_num;"
    self.json_dict["dt.condition_principal"] = "SELECT\n\tb.encounter_num\tAS\t\"condition_encounter_identifier_value\",\n\ta.concept_cd\tAS\t\"condition_code_coding_code\"\nFROM\n\ti2b2miracum.visit_dimension AS b\nLEFT OUTER JOIN (\nSELECT\n\tencounter_num, concept_cd\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'ICD%' AND modifier_cd = 'DIAGNOSEART:HD' AND observation_blob NOT LIKE 'Code 2 from%'\n) AS a ON\n\ta.encounter_num = b.encounter_num\nWHERE\n\tb.visit_blob = 'True encounter'\nORDER BY\n\tb.encounter_num;"
    self.json_dict["dt.conditioncategory"] = "SELECT\n\tb.encounter_num\tAS\t\"condition_encounter_identifier_value\",\n\ta.modifier_cd\tAS\t\"encounter_diagnosis_rank\"\nFROM\n\ti2b2miracum.visit_dimension AS b\nLEFT OUTER JOIN (\nSELECT\n\tencounter_num, modifier_cd\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'ICD%' AND observation_blob NOT LIKE 'Code 2 from%') AS a ON\n\ta.encounter_num = b.encounter_num\nWHERE\n\tb.visit_blob = 'True encounter'\nORDER BY\n\tb.encounter_num;"
    self.json_dict["dt.condition_secondary"] = "SELECT\n\tb.encounter_num\tAS\t\"condition_encounter_identifier_value\",\n\ta.concept_cd\tAS\t\"condition_code_coding_code_rank2\"\nFROM\n\ti2b2miracum.visit_dimension AS b\nLEFT OUTER JOIN (\nSELECT\n\tencounter_num, concept_cd\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'ICD%' AND modifier_cd = 'DIAGNOSEART:ND' AND observation_blob NOT LIKE 'Code 2 from%') AS a ON\n\ta.encounter_num = b.encounter_num\nWHERE\n\tb.visit_blob = 'True encounter'\nORDER BY\n\tb.encounter_num;"
    self.json_dict["dt.procedure"] = "SELECT\n\tencounter_num\tAS\t\"procedure_encounter_identifier_value\",\n\tconcept_cd\tAS\t\"procedure_code_coding_code\"\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'OPS%'\nORDER BY\n\tencounter_num;"
    self.json_dict["dt.proceduredate"] = "SELECT\n\tencounter_num\tAS\t\"procedure_encounter_identifier_value\",\n\tstart_date::date\tAS\t\"procedure_performedDateTime\"\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'OPS%'\nORDER BY\n\tencounter_num;"
    self.json_dict["dt.procedure_medication"] = "SELECT\n\tencounter_num\tAS\t\"procedure_encounter_identifier_value\",\n\tconcept_cd\tAS\t\"procedure_code_coding_code\"\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'OPS:6-00%'\nORDER BY\n\tencounter_num;"
    self.json_dict["dt.laboratory"] = "SELECT\n\tconcept_cd\tAS\t\"observation_code_coding_code\",\nencounter_num\tAS\t\"encounter_identifier_value\"\nFROM\n\ti2b2miracum.observation_fact\nWHERE\n\tconcept_cd LIKE 'LOINC%';"


if __name__ == "__main__":
  csql = CreateSQL()
  csql()
