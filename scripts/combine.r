library(here)
readRenviron(here("config.env"))

datadir <- Sys.getenv("datadir")
resultsdir <- Sys.getenv("resultsdir")

pred.protein.filename <- file.path(resultsdir, "predicted-proteins.txt")
clinical.filename <- file.path(resultsdir, "clinical-clean.txt")

source(here("scripts", "my-write-table-function.r"))

## get helper functions for parsing tcga ids
source(here("scripts", "extract-participant.r"))

pred.proteins <- read.table(pred.protein.filename,
  header = T, sep = "\t", stringsAsFactors = F
)

## extract participant tissue information
tissues <- data.frame(
  participant = extract.participant(rownames(pred.proteins)),
  tissue = extract.tissue(rownames(pred.proteins)),
  participant.tissue = paste(extract.participant(rownames(pred.proteins)),
    extract.tissue(rownames(pred.proteins)),
    sep = "-"
  )
)
tissues <- subset(tissues, tissue != "06" & tissue != "V582")

## update pred.proteins to use participant.tissue rownames
samples <- rownames(pred.proteins)
rownames(pred.proteins) <- paste(extract.participant(samples),
  extract.tissue(samples),
  sep = "-"
)

## get cleaned clinical data
clinical <- read.table(clinical.filename,
  header = T, sep = "\t", stringsAsFactors = F
)

## combine with participant tissue info from predicted protein dataset
clinical <- merge(clinical, tissues, by.x = "participant")
clinical$tumor.or.normal <- ifelse(as.numeric(clinical$tissue) < 9, "tumor", "normal")
clinical$tumor <- sign(clinical$tumor.or.normal == "tumor")


table(rownames(pred.proteins) %in% clinical$participant.tissue)

## combine the clinical info with the methylation predicted protein abundances
out <- cbind(
  clinical,
  pred.proteins[match(clinical$participant.tissue, rownames(pred.proteins)), ]
)

## export results
my.write.table(
  out,
  file.path(resultsdir, "combined-clin-pred-proteins.txt")
)
