FROM rocker/r-ver:4.4.2

RUN apt-get update
RUN apt-get install -y curl gdebi

## install quarto
ARG QUARTO_VERSION="1.6.42"
ARG QUARTO_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb"
RUN curl -o quarto-linux-amd64.deb -L ${QUARTO_URL}
RUN gdebi --non-interactive quarto-linux-amd64.deb

## set working directory for the pipeline
WORKDIR /home

# Copy pipeline scripts into the container
RUN mkdir -p scripts
COPY scripts/* scripts/

# Setup renv
RUN mkdir -p renv
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json
COPY renv.lock renv.lock

# Install R packages
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "renv::restore()"

CMD ["/bin/bash"]