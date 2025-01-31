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

## download the raw data from TCGA to the
## data directory
## no packages needed
system(paste("Rscript download-data.r", "files.csv", paths$data.dir))

## download the PanCancer Atlas clinical data
## to the data directory
## requires: readxl
source("download-pan-cancer-clinical.r",echo=T)
## out: TCGA-CDR-SupplementalTableS1.txt

## extract the relevant tcga tar.gz files 
## and generate appropriately named text
## files for each class of data
## requires: data.table
source("extract-data.r",echo=T)
## out: 
##  - clinical.txt
##  - protein.txt, protein-clean.txt
##  - methylation.txt, methylation-clean.txt