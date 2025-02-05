#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)

filename <- args[1]
output.dir <- args[2]

stopifnot(dir.exists(output.dir))

url <- "https://gdac.broadinstitute.org/runs/stddata__2016_01_28/data/HNSC/20160128"
files <- read.csv(filename, header=T, stringsAsFactors=F)
options(timeout = max(300, getOption("timeout")))
getOption("timeout")

for (filename in files$filename) {
    if (!file.exists(file.path(output.dir, filename)))
        download.file(
            url=file.path(url, filename),
            destfile=file.path(output.dir, filename))
}

files$bytes <- sapply(file.path(output.dir, files$filename), function(filename) {
    if (file.exists(filename))
        file.info(filename)$size
    else
        NA
})

files$downloaded.size <- files$bytes
idx <- which(files$bytes >= 2^30)
files$downloaded.size[idx] <- paste0(round(files$bytes[idx]/2^30,1), "G")
idx <- which(files$bytes >= 2^20 & files$bytes < 2^30)
files$downloaded.size[idx] <- paste0(round(files$bytes[idx]/2^20,1), "M")
idx <- which(files$bytes >= 2^10 & files$bytes < 2^20)
files$downloaded.size[idx] <- paste0(round(files$bytes[idx]/2^10,1), "K")

files[,c("size","downloaded.size")]
##     size downloaded.size
## 1    37M           36.8M
## 2    199             199
## 3    831             831
## ...
