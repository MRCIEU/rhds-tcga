#args <- c("hnsc-project/data/methylation-dataset")
args = commandArgs(trailingOnly=TRUE)

methylation.dir <- args[1]
methylation.file <- file.path(methylation.dir, "methylation.txt")

## Start to Process Files 

my.read.table <- function(filename, ...) {
	require(data.table)
    cat("reading", basename(filename), "... ")
    x <- fread(
        filename,
        header=T,
        stringsAsFactors=F,
        sep="\t",
        ...)
    cat(nrow(x), "x", ncol(x), "\n")
    as.data.frame(x,stringsAsFactors=F)
}
data <- my.read.table(methylation.file)
	index <- grep("Hybrid", colnames(data))
	rownames(data) <- data[,index[1]]
	data <- as.matrix(data[, -index])

    ## drop rows that are completely missing
    index.na.row <- apply(data, 1, function(i) all(!is.na(i)))
    data <- data[index.na.row, ]

## check number of rows missing per sample
#miss <- apply(data, 2, function(i) table(is.na(i)), simplify=F)
#miss.df <- as.data.frame(do.call(rbind, miss))
#summary(miss.df$"TRUE")

## Before the all na row drop above ~90k observations
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#  89519   89566   89645   89790   89817   95558


library(meffonym)
library(tidyverse)

models <- meffonym.models(full=T) %>%
            filter(str_detect(filename, "^episcores"))

proteins <- models %>% pull(name)


predicted.proteins <- t(sapply(
        proteins,
        function(model) {
            cat(date(), model, " ")
            ret <- meffonym.score(data, model)
            cat(" used ", length(ret$sites), "/", length(ret$vars), "sites\n")
            ret$score
        }))

colnames(predicted.proteins) <- colnames(data)

my.write.table <- function(x, filename) {
    cat("saving", basename(filename), "...\n")
    write.table(x, file=filename, row.names=T, col.names=T, sep="\t")
}

my.write.table(predicted.proteins, file.path(methylation.dir, "predicted-proteins.txt"))
write_rds(predicted.proteins, file.path(methylation.dir, "predicted-proteins.rds"))




