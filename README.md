# Prediction of cancer progression from imputed proteomics

## Setup

Create a `config.env` file based on `config-template.env` that will have the following variables:

```
datadir=/path/to/data
resultsdir=/path/to/results
```

The data directory is for raw downloaded data that ideally you won't modify.

The results directory is for intermediate steps and final results. All files in the results directory should be reproducible.

## Run analysis

To run the analysis you need R packages installed using the [`renv`](https://rstudio.github.io/renv/articles/renv.html) package manager:

```R
install.packages("renv")
renv::restore()
```

This will run everything:

```bash
Rscript run-all.r
```
