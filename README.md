# miRacumDQA  

<!-- badges: start -->
[![pipeline status](https://gitlab.miracum.org/miracum/dqa/miracumdqa/badges/master/pipeline.svg)](https://gitlab.miracum.org/miracum/dqa/miracumdqa/-/commits/master)
[![coverage report](https://gitlab.miracum.org/miracum/dqa/miracumdqa/badges/master/coverage.svg)](https://gitlab.miracum.org/miracum/dqa/miracumdqa/-/commits/master)
<!-- badges: end -->

This is the repository of the MIRACUM data quality assessment tool (DQA tool). 

## Installation

You can install the with the following commands. Please make sure to also install the required packages in the correct order.

``` r
install.packages("remotes")
remotes::install_git("https://gitlab.miracum.org/miracum/dqa/miracumdqa.git")
```

## Configuration 

The database connection can be configured using environment variables. These can be set using the base R command `Sys.setenv()`.

A detailed description, which environment variables need to be set for the specific databases can be found [here](https://github.com/miracum/misc-dizutils#db_connection).

## Example

This is a basic example which shows you how to launch the MIRACUM DQA tool:

``` r
library(miRacumDQA)
launch_dqa_tool()
```

To open the shiny application in your web-browser, go to http://localhost:3838.

## Adding of new Dataelements to be Analyzed

- MDR: [inst/application/_utilities/MDR/mdr.csv](inst/application/_utilities/MDR/mdr.csv)
- Update MDR: [https://gitlab.miracum.org/miracum/dqa/miracumdqa/-/blob/development/inst/application/_utilities/MDR/update_dehub_mdr.py](https://gitlab.miracum.org/miracum/dqa/miracumdqa/-/blob/development/inst/application/_utilities/MDR/update_dehub_mdr.py)
- Plausibilities: [/inst/application/_utilities/MDR/plausibilities.py](/inst/application/_utilities/MDR/plausibilities.py)
- Constraints: [/inst/application/_utilities/MDR/plausibilities.py](/inst/application/_utilities/MDR/constraints.py)
- Add SQL-statements:
  * i2b2: [inst/application/_utilities/SQL/create_i2b2.py](inst/application/_utilities/SQL/create_i2b2.py)
  * fhir_gw: [inst/application/_utilities/SQL/create_fhir_gw.py](inst/application/_utilities/SQL/create_fhir_gw.py)
  * omop: [inst/application/_utilities/SQL/create_omop.py](inst/application/_utilities/SQL/create_omop.py)

## MDR-Connection

The MIRACUM DQA-tool is directly connected with the MIRACUM metadata repository (MDR). The python library [`dqa-mdr-connector`](https://github.com/miracum/dqa-mdr-connector) is used (via the fabulous R package [`reticulate`](https://rstudio.github.io/reticulate/)) to download the metadata specifications of the dataelements to be analyzed with the DQA-tool from the MDR.

## `DQAstats`-Wiki

Details on the background and the functioning of the DQA-tool as well as on specific configurations are available form the [`DQAstats` Wiki-page](https://github.com/miracum/dqa-dqastats/wiki).

# More Infos:

- about MIRACUM: [https://www.miracum.org/](https://www.miracum.org/)
- about the Medical Informatics Initiative: [https://www.medizininformatik-initiative.de/index.php/de](https://www.medizininformatik-initiative.de/index.php/de)
- about Shiny: https://www.rstudio.com/products/shiny/  
- RStudio and Shiny are trademarks of RStudio, Inc. 
