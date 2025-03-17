my.read.table <- function(filename, ...) {
  require(data.table)
  cat("reading", basename(filename), "... ")
  x <- fread(
    filename,
    header = T,
    stringsAsFactors = F,
    sep = "\t",
    ...
  )
  cat(nrow(x), "x", ncol(x), "\n")
  as.data.frame(x, stringsAsFactors = F)
}
