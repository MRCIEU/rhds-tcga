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
source("extract-data.r",echo=T)
## out: 
##  - clinical.txt
##  - protein.txt, protein-clean.txt
##  - methylation.txt, methylation-clean.txt

## clean the clinical phenotyping data
## in: clinical.txt, TCGA-CDR-SupplementalTableS1.txt
source("clean-clinical.r",echo=T)
## out: clinical-clean.txt

## estimate predicted protein abundances from 
## dna methylation data 
## in: methylation-clean.txt
source("predict-proteins.r",echo=T)
## out: predicted-proteins.txt

## combine clinical data and methylation 
## predicted protein abundance into one analysis
## ready dataset  
## in: predicted-proteins.txt, clinical-clean.txt
source("combine.r",echo=T)
## out: combined-clin-pred-proteins.txt

## run analysis looking at relationship between
## methylation predicted proteins and 
## tumor vs. normal tissue type. 
## render an html summary
packages <- c("rmarkdown", "knitr")
lapply(packages, require, character.only=T)

render("analysis.rmd", 
	output_format = "all")
