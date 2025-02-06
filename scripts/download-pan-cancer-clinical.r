library(readxl)
library(here)
readRenviron(here("config.env"))

datadir <- Sys.getenv("datadir")
resultsdir <- Sys.getenv("resultsdir")

stopifnot(dir.exists(datadir))

# url & filename for clinical outcome data from the PanCancer Atlas project
# (https://gdc.cancer.gov/about-data/publications/pancanatlas)
url <- "https://api.gdc.cancer.gov/data/1b5f413e-a8d1-4d10-92eb-7c4ae739ed81"
filename <- "TCGA-CDR-SupplementalTableS1.xlsx"

cat("download-pan-cancer-clinical.r", filename, "\n")
if (!file.exists(file.path(datadir, filename))) {
  download.file(
    url,
    destfile = file.path(datadir, filename)
  )
}

# save a tab-seperated vesion
dat <- read_xlsx(file.path(datadir, filename), sheet = 1)
write.table(
  dat,
  file = file.path(datadir, sub("xlsx$", "txt", filename)),
  sep = "\t", row.names = F, col.names = T
)
