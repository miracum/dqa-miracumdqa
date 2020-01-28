FROM rocker/shiny-verse:3.6.2

# install necessary system dependencies for r packages (e.g. devtools, RPostgres)
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    pandoc \
    pandoc-citeproc \
    git

# set cran repo
RUN echo "options('repos' = 'https://ftp.fau.de/cran/')" >> /usr/local/lib/R/etc/Rprofile.site

ENV PATH="/home/shiny/bin:${PATH}"

# install required LaTeX-Packages
RUN tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet && \
    tlmgr update --self && \
    tlmgr install \
    amsfonts \
    amsmath \
    atbegshi \
    atveryend \
    babel \
    babel-german \
    bigintcalc \
    bitset \
    caption \
    colortbl \
    ec \
    environ \
    epstopdf-pkg \
    etexcmds \
    float \
    geometry \
    gettitlestring \
    graphics \
    graphics-def \
    hycolor \
    hyperref \
    hyphen-german \
    iftex \
    intcalc \
    koma-script \
    kvdefinekeys \
    kvsetkeys \
    latex-graphics-dev \
    letltxmacro \
    lm \
    ltxcmds \
    makecell \
    multirow \
    oberdiek \
    pdfescape \
    pdflscape \
    refcount \
    rerunfilecheck \
    tabu \
    tex-gyre-math \
    threeparttable \
    threeparttablex \
    titling \
    tools \
    trimspaces \
    uniquecounter \
    varwidth \
    wrapfig \
    ulem \
    url \
    xcolor

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
