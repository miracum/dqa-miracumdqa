FROM rocker/shiny-verse:3.6.1

# install necessary system dependencies for r packages (e.g. devtools, RPostgres)
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    pandoc \
    pandoc-citeproc \
    git

# set cran repo
RUN echo "options('repos' = 'https://ftp.fau.de/cran/')" >> /usr/local/lib/R/etc/Rprofile.site

# install tinytex
USER shiny
RUN R -q -e "tinytex::install_tinytex()"
USER root

ENV PATH="/home/shiny/bin:${PATH}"

# install required LaTeX-Packages
RUN tlmgr update --self \
    tlmgr install \
    amsfonts \
    amsmath \
    babel \
    babel-german \
    caption \
    colortbl \
    ec \
    environ \
    float \
    geometry \
    graphics \
    graphics-def \
    epstopdf-pkg \
    hyperref \
    hyphen-german \
    iftex \
    koma-script \
    lm \
    makecell \
    multirow \
    oberdiek \
    pdflscape \
    tabu \
    tex-gyre-math \
    threeparttable \
    threeparttablex \
    titling \
    tools \
    trimspaces \
    varwidth \
    wrapfig \
    ulem \
    url \
    xcolor

# add cloned repo
COPY ./addfolder /home/shiny/

# repository name
ARG REPO_NAME=miracumdqa

# install our R-Package
RUN cd /home/shiny/${REPO_NAME}/ && \
    R -q -e "devtools::install('.')"

# add shiny app
RUN cd /home/shiny/${REPO_NAME}/docker && \
    cp app.R /srv/shiny-server/ && \
    # add custom server conf (running shiny as user 'shiny' is more secure than running as 'root')
    cp shiny-server.conf /etc/shiny-server/ && \
    # add log-script
    cp show-log.sh /

# fix permissions
RUN chown -R shiny:shiny /srv/shiny-server/
RUN chmod +x show-log.sh

# https://stackoverflow.com/questions/51080857/preserve-environment-variables-when-spawning-shiny-processes-within-a-container?rq=1
ENTRYPOINT env >> /home/shiny/.Renviron && \
    chown shiny.shiny /home/shiny/.Renviron && \
    /usr/bin/shiny-server.sh
