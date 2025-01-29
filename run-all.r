args <- commandArgs(trailingOnly=TRUE)

config.name <- "default"
if (length(args) > 0)
    config.name <- args[1]

paths <- config::get(config=config.name)
print(paths)

paths$data.dir <- file.path(paths$project.dir, "data")
paths$output.dir <- file.path(paths$project.dir, "results")
print(paths)

## Check for and where needed install
## r packages required for the 
## remainder of the analysis
source("install-packages.r",echo=T)

## download the raw data from TCGA
## no packages needed
system(paste("Rscript download-data.r", "files.csv", paths$data.dir))

