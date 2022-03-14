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
from python_mdr_handling import MDRHandling



class WritePlausibilities(MDRHandling):
  
  def __init__(self, **kwargs):
    """
    Instantiate some basics.
    """
    super().__init__(**kwargs)
    
    self.mdr["plausibility_relation"] = ""
    
  
  def __call__(self):
    """
    Our main function.
    """
    self.add_plausibilities()
    
    self.write_mdr(filename="mdr.csv")
  
  
  def add_plausibilities(self):
    
    self.mdr.loc[
      (self.mdr.designation == "Patienten-Identifikator") &
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
      (self.mdr.designation == "Aufnahmenummer") &
      (self.mdr.dqa_assessment == "1"),
      "plausibility_relation"] = json.dumps(
        {
          "uniqueness": {
            "Person.PatientIn.Patienten-Identifikator.Patienten-Identifikator": {
              "name": "Pl.uniqueness.Item02",
              "description": "Mit jeder Fallnummer darf nur eine Patienten-ID assoziiert sein."
            }
          }
        }
      )

    self.mdr.loc[
      (self.mdr.designation == "AdministrativesGeschlecht") &
      (self.mdr.dqa_assessment == "1"),
      "plausibility_relation"] = json.dumps(
        {
          "atemporal": {
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode": {
              "name": "Pl.atemporal.Item01",
              "description": "Nur bei weiblichen Patientinnen ist eine ICD-Diagnose aus dem ICD-Kapitel XV (ICD O00-O99) (Schwangerschaft, Geburt und Wochenbett) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)O[0-9]",
                "fhir_gw": "^O[0-9]"
              },
              "join_crit": "Fall.Einrichtungskontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.1": {
              "name": "Pl.atemporal.Item02",
              "description": "Nur bei weiblichen Patientinnen sind bösartige Neubildungen der weiblichen Genitalorgane (ICD C51-C58) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)C5[1-8]",
                "fhir_gw": "^C5[1-8]"
              },
              "join_crit": "Fall.Einrichtungskontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.2": {
              "name": "Pl.atemporal.Item03",
              "description": "Nur bei männlichen Patienten sind bösartige Neubildungen der männlichen Genitalorgane (ICD C60-C63) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)C6[0-3]",
                "fhir_gw": "^C6[0-3]"
              },
              "join_crit": "Fall.Einrichtungskontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:male",
                  "fhir_gw": "male",
                  "omop": "male"
                }
              }
            }
          }
        }
      )
    
    

if __name__ == "__main__":
  wrpl = WritePlausibilities(mdr_file="mdr.csv")
  wrpl()
