FROM r-base

# install necessary system dependencies for r packages (e.g. devtools, RPostgres)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev \
    apt-utils \
    libcurl4-openssl-dev \
    libssl-dev \
    libpq-dev \
    pandoc \
    pandoc-citeproc \
    gpg-agent


ARG p_base="devtools \
    git2r \
    getPass"

RUN for package in $p_base; do \
    R -q -e "p <- \"$package\"; if (isFALSE(p %in% installed.packages()[,\"Package\"])){; cat(paste(\"Installing package:\", p, \"\n\n\")); install.packages(p, repos = \"https://ftp.fau.de/cran/\", quiet=T);} else {;cat(paste(\"Package\", p, \"is already installed\n\n\"));}"; \
    done

ARG gitpassword
ARG gitusername

# install our R-Package
RUN R -q -e "devtools::install_git('https://gitlab.miracum.org/miracum-dqa/miRacumDQA.git', credentials = git2r::cred_user_pass(\"$gitusername\", \"$gitpassword\"))" #, ref = \"v1.3.1.9003\")"

# install tinytex
RUN R -q -e "install.packages('tinytex')"
RUN R -q -e 'tinytex::install_tinytex()'

# install required LaTeX-Packages
RUN ./root/.TinyTeX/bin/x86_64-linux/tlmgr update --self
RUN ./root/.TinyTeX/bin/x86_64-linux/tlmgr install \
    multirow \
    xcolor \
    colortbl \
    wrapfig \
    float \
    tabu \
    varwidth \
    threeparttable \
    threeparttablex \
    environ \
    trimspaces \
    ulem \
    makecell \
    babel \
    babel-german \
    hyphen-german \
    lm \
    hyperref \
    url \
    graphics-def \
    titling \
    caption \
    amsmath \
    amsfonts


RUN echo "options(shiny.port = 3838)" >> /etc/R/Rprofile.site && \
    echo "options(shiny.host = '0.0.0.0')" >> /etc/R/Rprofile.site && \
    echo "options(shiny.launch.browser = FALSE)" >> /etc/R/Rprofile.site


# add log-script
ADD show-log.sh /
RUN chmod +x show-log.sh

CMD ["R", "-e library(miRacumDQA);launchApp()"]
