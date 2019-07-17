# miRacumDQA  

This is the repository of the MIRACUM data quality assessment tool (DQA tool). 

## Docker 

To build a deployable docker container run:

```
cd ./docker/
chmod +x build_image.sh
./build_image.sh
```

## Installation

You can install the development version of miRacumDQA with:

``` r
install.packages("devtools")
devtools::install_git("https://gitlab.miracum.org/miracum-dqa/miRacumDQA.git")
```

## Example

This is a basic example which shows you how to launch the MIRACUM DQA tool:

``` r
library(miRacumDQA)
miRacumDQA()
```

# More Infos:
- about Shiny: https://www.rstudio.com/products/shiny/  
- RStudio and Shiny are trademarks of RStudio, Inc.  
