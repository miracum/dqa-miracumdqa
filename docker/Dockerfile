FROM rocker/shiny-verse:3.6.1

# install necessary system dependencies for r packages (e.g. devtools, RPostgres)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev \
    apt-utils \
    libcurl4-openssl-dev \
    libssl-dev \
    libpq-dev \
    pandoc \
    pandoc-citeproc \
    gpg-agent \
    git

# set cran repo
RUN echo "options('repos' = 'https://ftp.fau.de/cran/')" >> /usr/local/lib/R/etc/Rprofile.site

# install tinytex
RUN R -q -e "remotes::update_packages(packages = \"tinytex\", upgrade = \"always\")"

USER shiny
RUN R -q -e "tinytex::install_tinytex()"
USER root

ENV PATH="/home/shiny/bin:${PATH}"

# install required LaTeX-Packages
RUN tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet && \
    tlmgr update --self && \
    tlmgr install \
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
    amsfonts \
    tools \
    oberdiek \
    graphics \
    latex-graphics-dev \
    geometry \
    ec \
    iftex

# repository name
ARG REPO_NAME=dqastats

# add cloned repo
COPY ./addfolder /home/shiny/

# install our R-Package
RUN cd /home/shiny/${REPO_NAME}/ && \
    R -q -e "devtools::install('.')"

# repository name
ARG REPO_NAME=dqagui

# install our R-Package
RUN cd /home/shiny/${REPO_NAME}/ && \
    R -q -e "devtools::install('.')"

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

CMD ["/usr/bin/shiny-server.sh"]
