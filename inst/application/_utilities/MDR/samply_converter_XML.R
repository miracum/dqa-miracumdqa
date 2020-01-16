# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2020 Universitätsklinikum Erlangen
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
library(XML)
library(xslt)
library(xml2)
library(flatxml)
library(magrittr)
# http://web.mit.edu/~r/current/arch/i386_linux26/lib/R/library/XML/html/xmlSchemaValidate.html
# https://stackoverflow.com/questions/46690742/xml-to-list-and-back-to-xml
# https://stackoverflow.com/questions/48510579/extracting-schema-information-from-xml-to-a-data-frame

xsd <- xml2::read_xml("./inst/application/_utilities/MDR/XSD/common.xsd")

xsd2 <- XML::xmlToList("./inst/application/_utilities/MDR/XSD/common.xsd")
xsd3 <- XML::xml("./inst/application/_utilities/MDR/XSD/common.xsd")


flatxml1 <- flatxml::fxml_importXMLFlat("./inst/application/_utilities/MDR/XSD/common.xsd")



# tutorial: https://subscription.packtpub.com/book/big_data_and_business_intelligence/9781783989065/1/ch01lvl1sec11/reading-xml-data
url <- "./inst/application/_utilities/MDR/XSD/common.xsd"
xmldoc <- xmlParse(url)
rootNode <- xmlRoot(xmldoc)
rootNode[4]
data <- xmlSApply(rootNode,function(x) xmlSApply(x, xmlValue))



# schema
xr <- xml2::read_xml(url)

nodeset <- xml2::xml_children(xr)


# https://dantonnoriega.github.io/ultinomics.org/post/2017-04-18-xmltools-package.html
nodeset %>% xml2::xml_structure()


for (i in xr){
  print(i)
}





st <- xml2::xml_structure(url)



xr <- xml2::read_xml(url) %>%
  xml2::as_list()





# https://stackoverflow.com/questions/48510579/extracting-schema-information-from-xml-to-a-data-frame
get_stuff <- function(y, stuff) { unlist(lapply(y, function(x) x[[stuff]])) }

xml_list <- xml2::read_xml("./inst/application/_utilities/MDR/XSD/common.xsd")[["schema"]][["complexType"]][["sequence"]]

DF <- data.frame(name = get_stuff(xml_list, "name"),
                 type = get_stuff(xml_list, "type"),
                 minOccurs = get_stuff(xml_list, "minOccurs"),
                 maxOccurs = get_stuff(xml_list, "maxOccurs"),
                 saw_sql_type = get_stuff(xml_list, "type"),
                 saw_sql_displayFormula = get_stuff(xml_list, "displayFormula"))





sc <- XML::xmlTreeParse("./inst/application/_utilities/MDR/XSD/common.xsd")

XML::xmlChildren(sc)
