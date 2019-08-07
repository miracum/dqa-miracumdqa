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
devtools::install_git("https://gitlab.miracum.org/miracum-dqa/dqastats.git", credentials = git2r::cred_user_pass(rstudioapi::askForPassword(prompt = "Username"), rstudioapi::askForPassword()))
devtools::install_git("https://gitlab.miracum.org/miracum-dqa/dqagui.git", credentials = git2r::cred_user_pass(rstudioapi::askForPassword(prompt = "Username"), rstudioapi::askForPassword()))
devtools::install_git("https://gitlab.miracum.org/miracum-dqa/miracumdqa.git", credentials = git2r::cred_user_pass(rstudioapi::askForPassword(prompt = "Username"), rstudioapi::askForPassword()))
```

## Example

This is a basic example which shows you how to launch the MIRACUM DQA tool:

``` r
library(miRacumDQA)
launchApp()
```

To open the shiny application in your webbrowser, go to http://localhost:3838


# More Infos:
- about Shiny: https://www.rstudio.com/products/shiny/  
- RStudio and Shiny are trademarks of RStudio, Inc.  
