library(here)

readRenviron(here("config.env"))
datadir <- Sys.getenv("datadir")
resultsdir <- Sys.getenv("resultsdir")

## function for extracting tcga tar.gz's to named output
extract.file <- function(tar.file, extract.file, new.file) {
  # get file path to extracted file
  x.file <-
    grep(extract.file,
      untar(tar.file, list = T),
      value = T
    )
    
  # extract the tar file
  cat("Extracting", tar.file, "to", new.file, "\n")
  untar(tar.file, exdir=resultsdir, extras="--no-same-owner")
  x.file = file.path(resultsdir,x.file)

  # move the data to named output
  file.copy(x.file, new.file)

  # remove untared directory
  unlink(dirname(x.file), recursive = TRUE)
}

#######################
## extract the clinical data
clinical.file <- file.path(resultsdir, "clinical.txt")
if (!file.exists(clinical.file)) {
  extract.file(
    tar.file =
      file.path(
        datadir,
        grep(".*_HNSC\\..*_Clinical\\.Level_1\\..*\\.tar\\.gz$",
          list.files(datadir),
          value = T
        )
      ),
    extract.file = "HNSC.clin.merged.txt",
    new.file = clinical.file
  )
}


########################
## extract the protein data
protein.file <- file.path(resultsdir, "protein.txt")
if (!file.exists(protein.file)) {
  extract.file(
    tar.file =
      file.path(
        datadir,
        grep("*_protein_normalization__data.Level_3.*.tar.gz$",
          list.files(datadir),
          value = T
        )
      ),
    extract.file = "data.txt",
    new.file = protein.file
  )
}
## clean protein output:
## 	- remove 2nd row
lines <- readLines(protein.file)[-2]
writeLines(lines, file.path(resultsdir, "protein-clean.txt"))


########################
## methylation data is pre-extracted into the 'methylation-clean-score-sites.csv' file
