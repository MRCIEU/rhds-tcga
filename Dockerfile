FROM rocker/r-ver:4.4.2

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

