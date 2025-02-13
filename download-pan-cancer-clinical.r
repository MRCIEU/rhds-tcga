library(readxl)

url <- "https://api.gdc.cancer.gov/data/1b5f413e-a8d1-4d10-92eb-7c4ae739ed81"
filename <- "TCGA-CDR-SupplementalTableS1.xlsx"
cat("download-pan-cancer-clinical.r", filename, "\n")
if (!file.exists(file.path(filename))) {download.file(url,destfile = file.path(filename))}
dat<-read_xlsx(file.path(filename), sheet = 1)
write.table(dat,file = file.path(sub("xlsx$", "txt", filename)),sep = "\t", row.names = F, col.names = T)
