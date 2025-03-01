FROM rocker/r-ver:4.4.2

## create working directory for the project
RUN mkdir -p /project
WORKDIR /project

# Copy pipeline scripts into the container
RUN mkdir -p scripts
COPY scripts/* scripts/

# Setup renv
RUN mkdir -p renv
ENV RENV_PATHS_LIBRARY renv/library
COPY renv.lock renv.lock

# Install R packages
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "renv::restore()"

## install quarto
ARG QUARTO_VERSION="1.6.42"
RUN curl -o quarto-linux-amd64.deb -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb
RUN gdebi --non-interactive quarto-linux-amd64.deb
