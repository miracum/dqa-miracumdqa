FROM r-base

# install necessary system dependencies for r packages (e.g. devtools, RPostgres)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev \
    apt-utils \
    libcurl4-openssl-dev \
    libssl-dev \
    libpq-dev


ARG p_base="devtools \
    git2r \
    getPass"

RUN for package in $p_base; do \
    R -q -e "p <- \"$package\"; if (isFALSE(p %in% installed.packages()[,\"Package\"])){; cat(paste(\"Installing package:\", p, \"\n\n\")); install.packages(p, repos = \"https://ftp.fau.de/cran/\", quiet=T);} else {;cat(paste(\"Package\", p, \"is already installed\n\n\"));}"; \
    done

ARG gitusername
RUN echo $gitusername
ARG gitpassword

# install our R-Package
RUN R -q -e "devtools::install_git('https://gitlab.miracum.org/miracum-dqa/miRacumDQA.git', credentials = git2r::cred_user_pass(\"$gitusername\", \"$gitpassword\"))"

# install tinytex
RUN R -q -e 'tinytex::install_tinytex()'

RUN echo "options(shiny.port = 3838)" >> /etc/R/Rprofile.site && \
    echo "options(shiny.host = '0.0.0.0')" >> /etc/R/Rprofile.site && \
    echo "options(shiny.launch.browser = FALSE)" >> /etc/R/Rprofile.site

CMD ["R -e miRacumDQA::miRacumDQA()"]
