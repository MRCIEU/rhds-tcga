args <- commandArgs(trailingOnly=TRUE)
resultsdir <- args[1]

library(meffonym)

source("scripts/my-write-table-function.r")

methylation.file <- file.path(resultsdir, "methylation-clean-score-sites.csv.gz")

## read dnam file
data <- as.data.frame(data.table::fread(methylation.file))
rownames(data) <- data[,1]
data <- as.matrix(data[,-1])

## check number of rows missing per sample
# miss <- apply(data, 2, function(i) table(is.na(i)), simplify=F)
# miss.df <- as.data.frame(do.call(rbind, miss))
# summary(miss.df$"TRUE")

## Before the all na row drop above ~90k observations
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#  89519   89566   89645   89790   89817   95558

## get gadd et all episcores models
models <- subset(
  meffonym.models(full = T),
  grepl("^episcores", filename)
)

# get list of proteins to estimate
proteins <- models$name

# apply protein abundance coefs to dna methylation
pred.proteins <- sapply(
  proteins,
  function(model) {
    cat(date(), model, " ")
    ret <- meffonym.score(data, model)
    cat(
      " used ", length(ret$sites), "/",
      length(ret$vars), "sites\n"
    )
    ret$score
  }
)
rownames(pred.proteins) <- colnames(data)
pred.proteins <- scale(pred.proteins)
colnames(pred.proteins) <- make.names(colnames(pred.proteins))

## export results
my.write.table(
  pred.proteins,
  file.path(resultsdir, "predicted-proteins.txt")
)
