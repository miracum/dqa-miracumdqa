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
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
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
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
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
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:male",
                  "fhir_gw": "male",
                  "omop": "male"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.3": {
              "name": "Pl.atemporal.Item04",
              "description": "Nur bei weiblichen Patientinnen sind nichtentzündliche Krankheiten des weiblichen Genitaltraktes (ICD N80-N98) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)N[8-9][0-9]",
                "fhir_gw": "^N[8-9][0-9]"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.4": {
              "name": "Pl.atemporal.Item05",
              "description": "Nur bei männlichen Patienten ist Testikuläre Dysfunktion (ICD E29*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)E29",
                "fhir_gw": "^E29"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:male",
                  "fhir_gw": "male",
                  "omop": "male"
                }
              }
            },
            # "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.4": {
            #   "name": "Pl.atemporal.Item05",
            #   "description": "Nur bei weiblichen Patientinnen sind Krankheiten der Mamma [Brustdrüse] (ICD N60-N64) als Krankenhausdiagnose erlaubt.",
            #   "filter": {
            #     "i2b2": "^(ICD10\\:)N6[0-4]",
            #     "fhir_gw": "^N6[0-4]"
            #   },
            #   "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
            #   "constraints": {
            #   "value_set": {
            #       "i2b2": "Dem|Sex:female",
            #       "fhir_gw": "female",
            #       "omop": "female"
            #     }
            #   }
            # },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.5": {
              "name": "Pl.atemporal.Item06",
              "description": "Nur bei weiblichen Patientinnen sind Entzündliche Krankheiten der weiblichen Beckenorgane (ICD N70-N77) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)N7[0-7]",
                "fhir_gw": "^N7[0-7]"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.6": {
              "name": "Pl.atemporal.Item07",
              "description": "Nur bei männlichen Patienten sind Krankheiten der männlichen Genitalorgane (ICD N40-N51) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)N((4[0-9])|(5[0-1]))",
                "fhir_gw": "^N((4[0-9])|(5[0-1]))"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:male",
                  "fhir_gw": "male",
                  "omop": "male"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.7": {
              "name": "Pl.atemporal.Item08",
              "description": "Nur bei männlichen Patienten sind sonstige angeborene Fehlbildungen der männlichen Genitalorgane (ICD Q55*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)Q55",
                "fhir_gw": "^Q55"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:male",
                  "fhir_gw": "male",
                  "omop": "male"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.8": {
              "name": "Pl.atemporal.Item09",
              "description": "Nur bei männlichen Patienten ist Nondescensus testis (ICD Q53*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)Q53",
                "fhir_gw": "^Q53"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:male",
                  "fhir_gw": "male",
                  "omop": "male"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.9": {
              "name": "Pl.atemporal.Item10",
              "description": "Nur bei männlichen Patienten ist Hypospadie (ICD Q54*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)Q54",
                "fhir_gw": "^Q54"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:male",
                  "fhir_gw": "male",
                  "omop": "male"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.10": {
              "name": "Pl.atemporal.Item11",
              "description": "Nur bei weiblichen Patientinnen sind angeborene Fehlbildungen der Ovarien, der Tubae uterinae und der Ligg. lata uteri (ICD Q50*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)Q50",
                "fhir_gw": "^Q50"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.11": {
              "name": "Pl.atemporal.Item12",
              "description": "Nur bei weiblichen Patientinnen sind angeborene Fehlbildungen des Uterus und der Cervix uteri (ICD Q51*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)Q51",
                "fhir_gw": "^Q51"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.12": {
              "name": "Pl.atemporal.Item13",
              "description": "Nur bei weiblichen Patientinnen sind sonstige angeborene Fehlbildungen der weiblichen Genitalorgane (ICD Q52*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)Q52",
                "fhir_gw": "^Q52"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.13": {
              "name": "Pl.atemporal.Item14",
              "description": "Nur bei weiblichen Patientinnen sind abnorme Befunde in Untersuchungsmaterialien aus den weiblichen Genitalorganen (ICD R87*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)R87",
                "fhir_gw": "^R87"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.14": {
              "name": "Pl.atemporal.Item15",
              "description": "Nur bei männlichen Patienten sind abnorme Befunde in Untersuchungsmaterialien aus den männlichen Genitalorganen (ICD R86*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)R86",
                "fhir_gw": "^R86"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:male",
                  "fhir_gw": "male",
                  "omop": "male"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.15": {
              "name": "Pl.atemporal.Item16",
              "description": "Nur bei männlichen Patienten sind gutartige Neubildung der männlichen Genitalorgane (ICD D29*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)D29",
                "fhir_gw": "^D29"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:male",
                  "fhir_gw": "male",
                  "omop": "male"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.16": {
              "name": "Pl.atemporal.Item17",
              "description": "Nur bei weiblichen Patientinnen sind Leiomyom des Uterus (ICD D25*), sonstige gutartige Neubildungen des Uterus (ICD D26*), gutartige Neubildung des Ovars (ICD D27*) und gutartige Neubildung sonstiger und nicht näher bezeichneter weiblicher Genitalorgane (ICD D28*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)D2[5-8]",
                "fhir_gw": "^D2[5-8]"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.17": {
              "name": "Pl.atemporal.Item18",
              "description": "Nur bei weiblichen Patientinnen sind Neubildung unsicheren oder unbekannten Verhaltens der weiblichen Genitalorgane (ICD D39*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)D39",
                "fhir_gw": "^D39"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.18": {
              "name": "Pl.atemporal.Item19",
              "description": "Nur bei männlichen Patienten sind Neubildung unsicheren oder unbekannten Verhaltens der männlichen Genitalorgane (ICD D40*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)D40",
                "fhir_gw": "^D40"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:male",
                  "fhir_gw": "male",
                  "omop": "male"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.19": {
              "name": "Pl.atemporal.Item20",
              "description": "Nur bei männlichen Patienten sind Carcinoma in situ sonstiger und nicht näher bezeichneter Genitalorgane: Penis, Prostata, sonstige und nicht näher bezeichnete männliche Genitalorgane (ICD D07.4-6) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)D07\\.[4-6]",
                "fhir_gw": "^D07\\.[4-6]"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:male",
                  "fhir_gw": "male",
                  "omop": "male"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.20": {
              "name": "Pl.atemporal.Item21",
              "description": "Nur bei weiblichen Patientinnen sind Carcinoma in situ sonstiger und nicht näher bezeichneter Genitalorgane: Endometrium, Vulva, Vagina, sonstige und nicht näher bezeichnete weibliche Genitalorgane (ICD D07.0-3) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)D07\\.[0-3]",
                "fhir_gw": "^D07\\.[0-3]"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.21": {
              "name": "Pl.atemporal.Item22",
              "description": "Nur bei weiblichen Patientinnen ist Tetanus während der Schwangerschaft, der Geburt und des Wochenbettes (ICD A34) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)A34",
                "fhir_gw": "^A34"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.22": {
              "name": "Pl.atemporal.Item23",
              "description": "Nur bei weiblichen Patientinnen sind Psychische oder Verhaltensstörungen im Wochenbett, anderenorts nicht klassifiziert (ICD F53) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)F53",
                "fhir_gw": "^F53"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            },
            "Diagnose.ICD10GMDiagnoseKodiert.VollstaendigerDiagnosekode.23": {
              "name": "Pl.atemporal.Item24",
              "description": "Nur bei weiblichen Patientinnen ist Osteomalazie im Wochenbett (ICD M83.0*) als Krankenhausdiagnose erlaubt.",
              "filter": {
                "i2b2": "^(ICD10\\:)M83\\.0",
                "fhir_gw": "^M83\\.0"
              },
              "join_crit": "Fall.Versorgungsstellenkontakt.Aufnahmenummer",
              "constraints": {
              "value_set": {
                  "i2b2": "Dem|Sex:female",
                  "fhir_gw": "female",
                  "omop": "female"
                }
              }
            }
          }
        }
      )
    
    

if __name__ == "__main__":
  wrpl = WritePlausibilities(mdr_file="mdr.csv")
  wrpl()
