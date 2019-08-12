# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019 Universitätsklinikum Erlangen
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

library(data.table)

# read mdr
mdr <- fread(paste0(getwd(), "/inst/application/_utilities/MDR/mdr.csv"))
mdr[,value_set:=as.character(value_set)]
mdr[,("value_set"):=gsub("\"\"", "\"", get("value_set"))][get("value_set")=="",("value_set"):=NA]
mdr[,("plausibility_relation"):=gsub("\"\"", "\"", get("plausibility_relation"))][get("plausibility_relation")=="",("plausibility_relation"):=NA]

# Aufnahmeanlass
mdr[name=="Aufnahmeanlass" & source_system=="csv", value_set := '{"value_set": "E, Z, N, R, V, A, G, B"}']
mdr[name=="Aufnahmeanlass" & source_system=="i2b2", value_set := '{"value_set": "E, Z, N, R, V, A, G, B"}']

# Alter (in Tagen)
mdr[name=="Alter (in Tagen)" & source_system=="csv", value_set := '{"min": 0, "max": 366}']
mdr[name=="Alter (in Tagen)" & source_system=="i2b2", value_set := '{"min": 0, "max": 366}']

# Alter (in Jahren)
mdr[name=="Alter (in Jahren)" & source_system=="csv", value_set := '{"min": 0, "max": 110}']
mdr[name=="Alter (in Jahren)" & source_system=="i2b2", value_set := '{"min": 0, "max": 110}']

# Diagnoseart
mdr[name=="Diagnoseart" & source_system=="csv", value_set := '{"value_set": "HD, ND"}']
mdr[name=="Diagnoseart" & source_system=="i2b2", value_set := '{"value_set": "HD, ND"}']

# ICD Code
# TODO komplettes value_set zu aufwendig; ggf. Format mit regex testen?

# Fallnummer
# TODO value_set macht keinen Sinn; ggf. Format mit regex testen?

# Entlassungsgrund
mdr[name=="Entlassungsgrund" & source_system=="csv", value_set := '{"value_set": "01x, 02x, 03x, 04x, 059, 069, 079, 089, 099, 109, 119, 139, 14x, 15x, 179, 229, 239, 249, 259"}']
mdr[name=="Entlassungsgrund" & source_system=="i2b2", value_set := '{"value_set": "01x, 02x, 03x, 04x, 059, 069, 079, 089, 099, 109, 119, 139, 14x, 15x, 179, 229, 239, 249, 259"}']

# Entlassungsdatum, Aufnahmedatum, OPS Datum, Entlassungsdatum (Fachabteilung), Aufnahmedatum (Fachabteilung)
# TODO value_set für Datumsvariablen überlegen

# Aufnahmegrund
mdr[name=="Aufnahmegrund" & source_system=="csv", value_set := '{"value_set": "01xx, 02xx, 03xx, 04xx, 05xx, 06xx, 08xx"}']
mdr[name=="Aufnahmegrund" & source_system=="i2b2", value_set := '{"value_set": "01xx, 02xx, 03xx, 04xx, 05xx, 06xx, 08xx"}']

# Postleitzahl
# TODO komplettes value_set zu aufwendig; ggf. Format mit regex testen?

# Geburtsjahr
# TODO komplettes value_set zu aufwendig; ggf. Format mit regex testen? aka. "^19\\d{2}$"

# Geschlecht
mdr[name=="Geschlecht" & source_system=="csv", value_set := '{"value_set": "m, w, x"}']
mdr[name=="Geschlecht" & source_system=="i2b2", value_set := '{"value_set": "m, w, x"}']

# Patientennummer
# TODO value_set macht keinen Sinn; ggf. Format mit regex testen?

# OPS Code
# TODO komplettes value_set zu aufwendig; ggf. Format mit regex testen?

# Fachabteilung
# TODO komplettes value_set zu aufwendig; ggf. Format mit regex testen? "^HA|^BA|^BE\\d+$"

# Beatmungsstunden (365.25 Tage * 24 Stunden = 8766 Stunden)
mdr[name=="Beatmungsstunden" & source_system=="csv", value_set := '{"min": 0, "max": 8766}']
mdr[name=="Beatmungsstunden" & source_system=="i2b2", value_set := '{"min": 0, "max": 8766}']


# Plausibilities
# Item02
mdr[name=="Item02" & source_system=="csv", value_set := '{"value_set": "w"}']
mdr[name=="Item02" & source_system=="i2b2", value_set := '{"value_set": "w"}']

# Item03
mdr[name=="Item03" & source_system=="csv", value_set := '{"value_set": "w"}']
mdr[name=="Item03" & source_system=="i2b2", value_set := '{"value_set": "w"}']

# Item04
mdr[name=="Item04" & source_system=="csv", value_set := '{"value_set": "m"}']
mdr[name=="Item04" & source_system=="i2b2", value_set := '{"value_set": "m"}']

# Item05
mdr[name=="Item05" & source_system=="csv", value_set := '{"value_set": "w"}']
mdr[name=="Item05" & source_system=="i2b2", value_set := '{"value_set": "w"}']

# write mdr
fwrite(mdr, paste0(getwd(), "/inst/application/_utilities/MDR/mdr.csv"), sep = ";")

