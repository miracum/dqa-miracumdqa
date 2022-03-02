# miRacumDQA  

<!-- badges: start -->
[![pipeline status](https://gitlab.miracum.org/miracum/dqa/miracumdqa/badges/master/pipeline.svg)](https://gitlab.miracum.org/miracum/dqa/miracumdqa/commits/master)
[![coverage report](https://gitlab.miracum.org/miracum/dqa/miracumdqa/badges/master/coverage.svg)](https://gitlab.miracum.org/miracum/dqa/miracumdqa/commits/master)
<!-- badges: end -->

This is the repository of the MIRACUM data quality assessment tool (DQA tool). 

## Installation

You can install the with the following commands. Please make sure to also install the required packages in the correct order.

``` r
install.packages("remotes")
remotes::install_git("https://gitlab.miracum.org/miracum/dqa/miracumdqa.git")
```

# Configuration 

The database connection can be configured using environment variables. These can be set using the base R command `Sys.setenv()`.

A detailed description, which environment variables need to be set for the specific databases can be found [here](https://github.com/miracum/misc-dizutils#db_connection).

## Example

This is a basic example which shows you how to launch the MIRACUM DQA tool:

``` r
library(miRacumDQA)
launch_dqa_tool()
```

To open the shiny application in your web-browser, go to http://localhost:3838.

# More Infos:

- about MIRACUM: [https://www.miracum.org/](https://www.miracum.org/)
- about the Medical Informatics Initiative: [https://www.medizininformatik-initiative.de/index.php/de](https://www.medizininformatik-initiative.de/index.php/de)
- about Shiny: https://www.rstudio.com/products/shiny/  
- RStudio and Shiny are trademarks of RStudio, Inc. 
