my.write.table <- function(x, filename) {
  cat("saving", basename(filename), "...\n")
  write.table(x, file = filename, row.names = T, col.names = T, sep = "\t")
}
