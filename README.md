# miRacumDQA <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->
[![pipeline status](https://gitlab.miracum.org/miracum/dqa/miracumdqa/badges/master/pipeline.svg)](https://gitlab.miracum.org/miracum/dqa/miracumdqa/-/commits/master)
[![coverage report](https://gitlab.miracum.org/miracum/dqa/miracumdqa/badges/master/coverage.svg)](https://gitlab.miracum.org/miracum/dqa/miracumdqa/-/commits/master)
<!-- badges: end -->

This is the repository of the MIRACUM data quality assessment tool (DQA tool). The MIRACUM DQA tool is built upon the R packages [`DQAstats`](https://cran.r-project.org/package=DQAstats) and [`DQAgui`](https://cran.r-project.org/package=DQAgui), both available on [CRAN](https://cran.r-project.org).

Besides some customizations for application within the MIRACUM consortium, this repository contains the SQL statements to test the data quality of the MIRACUM research data repositories, as well as a wrapper to import the latest metadata from the centrally deployed [MIRACUM metadata repository (M-MDR)](https://dehub-dev.miracum.org/all-elements), which are required to perform the data quality checks. The latter is an enhancement compared to the default setting of `DQAstats`, which uses a CSV-table as MDR. 

In order to provide the information required to perform the DQ checks with `miRacumDQA` within the MDR, they first need to be added for each new data element to the CSV-file [`inst/application/_utilities/MDR/mdr.csv`](inst/application/_utilities/MDR/mdr.csv). This file then serves as input to the script [`inst/application/_utilities/MDR/update_dehub_mdr.py`](inst/application/_utilities/MDR/update_dehub_mdr.py), which uses the python library [`dqa-mdr-connector`](https://github.com/miracum/dqa-mdr-connector) (big thanks to @FFTibet for his support in developing this MDR-connector) to update the `dqa`-slots of the respective data elements in the M-MDR.

The following steps are required to let new data elements in the research data repositories be checked by the MIRACUM DQA tool:

  1. Add the required metadata to the CSV-MDR [`inst/application/_utilities/MDR/mdr.csv`](inst/application/_utilities/MDR/mdr.csv).
  2. Provide the required SQL statements to the appropriate python script in [`inst/application/_utilities/SQL`](inst/application/_utilities/SQL) and run the script to update the respective JSON-file that stores all SQL statements for the respective database.
  3. (optionally) Add appropriate value constraints and / or plausibility checks by adding them to the python scripts [`inst/application/_utilities/MDR/constraints.py`](inst/application/_utilities/MDR/constraints.py) and [`inst/application/_utilities/MDR/plausibilities.py`](inst/application/_utilities/MDR/plausibilities.py) and run those scripts as well.
  4. Add the data elements to the list in the file [`inst/application/_utilities/MDR/dqamdr_config.py`](inst/application/_utilities/MDR/dqamdr_config.py).
  5. Update the M-MDR by running the script [`inst/application/_utilities/MDR/update_dehub_mdr.py`](inst/application/_utilities/MDR/update_dehub_mdr.py) (please note that a user authentication is required to updated the centrally deployed metadata repository).
  6. Create a new version of this `miRacumDQA` R-package and distribute it to all MIRACUM sites (this step is yet required since the updated SQL statements are only shipped with this R package).
  
A more detailed description of the steps required to let the DQA tool analyze new data elements is provided in our [Wiki](https://github.com/miracum/dqa-dqastats/wiki).

Currently, the MIRACUM DQA tool is able to analyze data elements stored in the following research data repositories:

* MIRACUM i2b2 (postgres)
* MIRACUM [fhir-gateway](https://github.com/miracum/fhir-gateway) (postgres)
* OMOP (postgres) (!!! the SQL statements to analyze the OMOP research data repository are deprecated and currently not maintained !!!)

## Installation

You can install the with the following commands.

``` r
install.packages("remotes")
remotes::install_github("https://github.com/miracum/dqa-miracumdqa.git")
```

## Configuration 

The database connection can be configured using environment variables. These can be set using the base R command `Sys.setenv()`.

A detailed description, which environment variables need to be set for the specific databases can be found [here](https://github.com/miracum/misc-dizutils#db_connection).


## More Information:

- about MIRACUM: [https://www.miracum.org/](https://www.miracum.org/)
- about the Medical Informatics Initiative: [https://www.medizininformatik-initiative.de/index.php/de](https://www.medizininformatik-initiative.de/index.php/de)
- about Shiny: https://www.rstudio.com/products/shiny/  
- RStudio and Shiny are trademarks of RStudio, Inc. 
