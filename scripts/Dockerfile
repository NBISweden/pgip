# Docker file for workshop-pgip
# 2023 Per Unneberg

FROM rocker/verse:4.2.3
LABEL Description="Docker image for NBIS workshop Population Genomics in Practice"
LABEL Maintainer="per.unneberg@nbis.se"
LABEL org.opencontainers.image.source="https://github.com/NBISweden/workshop-pgip"
ARG QUARTO_VERSION="1.3.450"
ENV PATH="${PATH}:/miniconda3/bin"

RUN apt-get update -y \
    && apt-get install --no-install-recommends -y \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libudunits2-dev \
    libgdal-dev \
    texlive \
    texlive-latex-extra \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm -rf ./google-chrome-stable_current_amd64.deb \
    && curl -o quarto-linux-amd64.deb -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb \
    && apt-get install -y ./quarto-linux-amd64.deb \
    && rm -rf ./quarto-linux-amd64.deb \
    && Rscript -e 'install.packages(c("ape", "codetools", "curl", "devtools", "dt", "dygraphs", "expm", "fontawesome", "formatr"), repos = "http://cran.us.r-project.org");' \
    && Rscript -e 'install.packages(c("formattable", "gganimate", "ggiraph", "ggraph", "ggplot2", "gifski", "gplots"), repos = "http://cran.us.r-project.org");' \
    && Rscript -e 'install.packages(c("gsalib", "highcharter", "igraph", "kableExtra", "latex2exp", "leaflet"), repos = "http://cran.us.r-project.org");' \
    && Rscript -e 'install.packages(c("networkD3", "magick", "patchwork", "pdftools", "plotly", "readr", "readxl", "reticulate"), repos = "http://cran.us.r-project.org");' \
    && Rscript -e 'install.packages(c("rmarkdown", "tidyr", "viridis"), repos = "http://cran.us.r-project.org");' \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /qmd

RUN mkdir -p /miniconda3 \
    && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /miniconda3/miniconda.sh \
    && bash /miniconda3/miniconda.sh -b -u -p /miniconda3 \
    && rm -rf /miniconda3/miniconda.sh

RUN conda init bash

COPY env.yaml /tmp/env.yaml
RUN conda env update -n base -f /tmp/env.yaml
ENV PATH /miniconda3/envs/base/bin:$PATH
RUN /bin/bash -c "source activate base"

RUN python -m ipykernel install --user --display-name "Population Genomics in Practice (Python)"
RUN python -m pip install git+https://github.com/NBISweden/pgip-tools

RUN Rscript -e 'install.packages("dotenv", repos=c(CRAN = "https://cran.rstudio.com/"));' \
    R -e "library(devtools); devtools::install_local('../src/R/pgip', upgrade=FALSE)"

WORKDIR /qmd
ENV XDG_CACHE_HOME=/tmp/quarto_cache_home
ENV XDG_DATA_HOME=/tmp/quarto_data_home
CMD quarto render
