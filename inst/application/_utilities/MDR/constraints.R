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
mdr[,constraints:=as.character(constraints)]
mdr[,("constraints"):=gsub("\"\"", "\"", get("constraints"))][get("constraints")=="",("constraints"):=NA]
mdr[,("plausibility_relation"):=gsub("\"\"", "\"", get("plausibility_relation"))][get("plausibility_relation")=="",("plausibility_relation"):=NA]

# Aufnahmeanlass
c <- '{"value_set": "E, Z, N, R, V, A, G, B"}'
mdr[designation=="Aufnahmeanlass" & source_system=="p21csv", constraints := c]
mdr[designation=="Aufnahmeanlass" & source_system=="i2b2", constraints := c]
mdr[designation=="Aufnahmeanlass" & source_system=="omop", constraints := c]

# Alter (in Tagen)
c <- '{"range": {"min": 0, "max": 366, "unit": "d"}}'
mdr[designation=="Alter (in Tagen)" & source_system=="p21csv", constraints := c]
mdr[designation=="Alter (in Tagen)" & source_system=="i2b2", constraints := c]
mdr[designation=="Alter (in Tagen)" & source_system=="omop", constraints := c]

# Alter (in Jahren)
c <- '{"range": {"min": 0, "max": 110, "unit": "a"}}'
mdr[designation=="Alter (in Jahren)" & source_system=="p21csv", constraints := c]
mdr[designation=="Alter (in Jahren)" & source_system=="i2b2", constraints := c]
mdr[designation=="Alter (in Jahren)" & source_system=="omop", constraints := c]

# Diagnoseart
c <- '{"value_set": "HD, ND"}'
mdr[designation=="Diagnoseart" & source_system=="p21csv", constraints := c]
mdr[designation=="Diagnoseart" & source_system=="i2b2", constraints := c]
mdr[designation=="Diagnoseart" & source_system=="omop", constraints := '{"value_set": "44786627, 44786629"}']

# ICD Code
# TODO komplettes value_set zu aufwendig; ggf. Format mit regex testen?

# Fallnummer
# TODO value_set macht keinen Sinn; ggf. Format mit regex testen?

# Entlassungsgrund
c <- '{"value_set": "01x, 02x, 03x, 04x, 059, 069, 079, 089, 099, 109, 119, 139, 14x, 15x, 179, 229, 239, 249, 259"}'
mdr[designation=="Entlassungsgrund" & source_system=="p21csv", constraints := c]
mdr[designation=="Entlassungsgrund" & source_system=="i2b2", constraints := c]
mdr[designation=="Entlassungsgrund" & source_system=="omop", constraints := c]

# Entlassungsdatum, Aufnahmedatum, OPS Datum, Entlassungsdatum (Fachabteilung), Aufnahmedatum (Fachabteilung)
# TODO value_set für Datumsvariablen überlegen

# Aufnahmegrund
c <- '{"value_set": "01xx, 02xx, 03xx, 04xx, 05xx, 06xx, 08xx"}'
mdr[designation=="Aufnahmegrund" & source_system=="p21csv", constraints := c]
mdr[designation=="Aufnahmegrund" & source_system=="i2b2", constraints := c]
mdr[designation=="Aufnahmegrund" & source_system=="omop", constraints := c]

# Postleitzahl
# TODO komplettes value_set zu aufwendig; ggf. Format mit regex testen?

# Geburtsjahr
# TODO komplettes value_set zu aufwendig; ggf. Format mit regex testen? aka. "^19\\d{2}$"

# Geschlecht
c <- '{"value_set": "m, w, x"}'
mdr[designation=="Geschlecht" & source_system=="p21csv", constraints := c]
mdr[designation=="Geschlecht" & source_system=="i2b2", constraints := c]
mdr[designation=="Geschlecht" & source_system=="omop", constraints := c]

# Patientennummer
# TODO value_set macht keinen Sinn; ggf. Format mit regex testen?

# OPS Code
# TODO komplettes value_set zu aufwendig; ggf. Format mit regex testen?

# Fachabteilung
# TODO komplettes value_set zu aufwendig; ggf. Format mit regex testen? "^HA|^BA|^BE\\d+$"

# Beatmungsstunden (365.25 Tage * 24 Stunden = 8766 Stunden)
c <- '{"range": {"min": 0, "max": 8766, "unit": "h"}}'
mdr[designation=="Beatmungsstunden" & source_system=="p21csv", constraints := c]
mdr[designation=="Beatmungsstunden" & source_system=="i2b2", constraints := c]
mdr[designation=="Beatmungsstunden" & source_system=="omop", constraints := c]

# write mdr
fwrite(mdr, paste0(getwd(), "/inst/application/_utilities/MDR/mdr.csv"), sep = ";")

