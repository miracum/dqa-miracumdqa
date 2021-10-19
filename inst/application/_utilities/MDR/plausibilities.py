import json
import os
import pandas as pd

from python_mdr_handling import MDRHandling



class WritePlausibilities(MDRHandling):
  
  def __init__(self):
    """
    Instantiate some basics.
    """
    super().__init__()
    
    self.mdr["plausibility_relation"] = ""
    
  
  def __call__(self):
    """
    Our main function.
    """
    self.add_plausibilities()
    
    self.write_mdr(filename="mdr.csv")
  
  
  def add_plausibilities(self):
    
    self.mdr.loc[
      (self.mdr.designation == "Person.Patient.Patienten-Identifikator.Patienten-Identifikator") &
      (self.mdr.source_system_name == "i2b2") &
      (self.mdr.dqa_assessment == "1"),
      "plausibility_relation"] = json.dumps(
        {
          "uniqueness": {
            "Person.Demographie.Geburtsdatum": {
              "name": "Pl.uniqueness.Item01",
              "description": "Mit jeder Patienten-ID darf nur ein Geburtsjahr assoziiert sein."
            }
          }
        }
      )
      
    self.mdr.loc[
      (self.mdr.designation == "Fall.Einrichtungskontakt.Aufnahmenummer") &
      (self.mdr.source_system_name == "i2b2") &
      (self.mdr.dqa_assessment == "1"),
      "plausibility_relation"] = json.dumps(
        {
          "uniqueness": {
            "Person.Patient.Patienten-Identifikator.Patienten-Identifikator": {
              "name": "Pl.uniqueness.Item02",
              "description": "Mit jeder Fallnummer darf nur eine Patienten-ID assoziiert sein."
            }
          }
        }
      )
      
    self.mdr.loc[
      (self.mdr.designation == "Person.Demographie.AdministrativesGeschlecht") &
      (self.mdr.source_system_name == "i2b2") &
      (self.mdr.dqa_assessment == "1"),
      "plausibility_relation"] = json.dumps(
        {
          "atemporal": {
            "Diagnose.ICD10GMDiagnoseKodiert.VollständigerDiagnosecode": {
              "name": "Pl.atemporal.Item01",
              "description": "Nur bei weiblichen Patientinnen ist eine ICD-Diagnose aus dem ICD-Kapitel XV (ICD O00-O99) (Schwangerschaft, Geburt und Wochenbett) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)O[0-9]"
              },
              "join_crit": "Fall.Einrichtungskontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "DEM|GESCHLECHT:w"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollständigerDiagnosecode.1": {
              "name": "Pl.atemporal.Item02",
              "description": "Nur bei weiblichen Patientinnen sind bösartige Neubildungen der weiblichen Genitalorgane (ICD C51-C58) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)C5[1-8]"
              },
              "join_crit": "Fall.Einrichtungskontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "DEM|GESCHLECHT:w"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollständigerDiagnosecode.2": {
              "name": "Pl.atemporal.Item03",
              "description": "Nur bei männlichen Patienten sind bösartige Neubildungen der männlichen Genitalorgane (ICD C60-C63) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)C6[0-3]"
              },
              "join_crit": "Fall.Einrichtungskontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "DEM|GESCHLECHT:m"
                }
              }
            }
          }
        }
      )
    
    

if __name__ == "__main__":
  wrpl = WritePlausibilities()
  wrpl()
