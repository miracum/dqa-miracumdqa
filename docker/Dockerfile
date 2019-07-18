FROM r-base

RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev

ARG p_base="devtools"

RUN for package in $p_base; do \
    R -q -e "p <- \"$package\"; if (isFALSE(p %in% installed.packages()[,\"Package\"])){; cat(paste(\"Installing package:\", p, \"\n\n\")); install.packages(p, repos = \"https://ftp.fau.de/cran/\", quiet=T);} else {;cat(paste(\"Package\", p, \"is already installed\n\n\"));}"; \
    done

# install our R-Package
RUN R -q -e "devtools::install_git('https://gitlab.miracum.org/miracum-dqa/miRacumDQA.git')"

# install tinytex
RUN R -q -e 'tinytex::install_tinytex()'

CMD ["R -e miRacumDQA::miRacumDQA()"]
