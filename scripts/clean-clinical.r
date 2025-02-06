library(here)
readRenviron(here("config.env"))

datadir <- Sys.getenv("datadir")
resultsdir <- Sys.getenv("resultsdir")

clinical.filename <- file.path(datadir, "clinical.txt")
pan.cancer.filename <- file.path(datadir,
                        "TCGA-CDR-SupplementalTableS1.txt")
output.filename <- file.path(datadir, "clinical-clean.txt")

cat("extract-clinical.r",
    "\n ", clinical.filename,
    "\n ", pan.cancer.filename,
    "\n ", output.filename, "\n")

raw <- readLines(clinical.filename)
raw <- strsplit(raw, "\t")
raw <- sapply(raw, function(sample) sample)
colnames(raw) <- raw[1,]
raw <- raw[-1,]
raw <- as.data.frame(raw, stringsAsFactors=F)

clinical <- data.frame(
    participant=sub("[^-]+-[^-]+-", "", raw$patient.bcr_patient_barcode),
    stringsAsFactors=F)
clinical$participant <- toupper(clinical$participant)

clinical$female <- raw$patient.gender=="female"
clinical$histology <- raw$patient.tumor_samples.tumor_sample.tumor_histologies.tumor_histology.histological_type
clinical$age.at.diagnosis <- as.numeric(raw$patient.age_at_initial_pathologic_diagnosis)
clinical$estrogen.receptor.status <- raw$patient.breast_carcinoma_estrogen_receptor_status
clinical$progesterone.receptor.status <- raw$patient.breast_carcinoma_progesterone_receptor_status 
clinical$her2.status <- raw$patient.lab_proc_her2_neu_immunohistochemistry_receptor_status 
clinical$ethnicity <- raw$patient.ethnicity
clinical$race <- raw$patient.race_list.race
clinical$positive.lymphnodes <- as.numeric(raw$patient.number_of_lymphnodes_positive_by_he)
clinical$stage <- raw$patient.stage_event.pathologic_stage
clinical$tnm.m.category <- raw$patient.stage_event.tnm_categories.pathologic_categories.pathologic_m
clinical$tnm.n.category <- raw$patient.stage_event.tnm_categories.pathologic_categories.pathologic_n
clinical$tnm.t.category <- raw$patient.stage_event.tnm_categories.pathologic_categories.pathologic_t 
clinical$lymphocyte.infiltration <- as.numeric(raw$patient.samples.sample.portions.portion.slides.slide.percent_lymphocyte_infiltration)
clinical$monocyte.infiltration <- as.numeric(raw$patient.samples.sample.portions.portion.slides.slide.percent_monocyte_infiltration)
clinical$neutrophil.infiltration <- as.numeric(raw$patient.samples.sample.portions.portion.slides.slide.percent_neutrophil_infiltration)
clinical$necrosis.percent <- as.numeric(raw$patient.samples.sample.portions.portion.slides.slide.percent_necrosis)
clinical$normal.cells.percent <- as.numeric(raw$patient.samples.sample.portions.portion.slides.slide.percent_normal_cells)
clinical$stromal.cells.percent <- as.numeric(raw$patient.samples.sample.portions.portion.slides.slide.percent_stromal_cells)
clinical$tumor.cells.percent <- as.numeric(raw$patient.samples.sample.portions.portion.slides.slide.percent_tumor_cells)

clinical$stage[clinical$stage == "stage x"] <- NA

clinical$tnm.m.category <- factor(
    as.character(clinical$tnm.m.category),
    levels=c("m0","m1"))

clinical$tnm.t.category[clinical$tnm.t.category=="tx"] <- NA
clinical$tnm.t.category[grepl("t1", clinical$tnm.t.category)] <- "t1"
clinical$tnm.t.category[grepl("t2", clinical$tnm.t.category)] <- "t2"
clinical$tnm.t.category[grepl("t3", clinical$tnm.t.category)] <- "t3"
clinical$tnm.t.category[grepl("t4", clinical$tnm.t.category)] <- "t4"

clinical$tnm.n.category[clinical$tnm.n.category=="nx"] <- NA
clinical$tnm.n.category[grepl("n0", clinical$tnm.n.category)] <- "n0"
clinical$tnm.n.category[grepl("n1", clinical$tnm.n.category)] <- "n1"
clinical$tnm.n.category[grepl("n2", clinical$tnm.n.category)] <- "n2"
clinical$tnm.n.category[grepl("n3", clinical$tnm.n.category)] <- "n3"


clinical.pan <- read.table(pan.cancer.filename,header=T,sep="\t",stringsAsFactors=F)
clinical.pan <- clinical.pan[which(clinical.pan$type == "HNSC"),]
clinical.pan$participant <- sub("[^-]+-[^-]+-", "", clinical.pan$bcr_patient_barcode)
clinical.pan <- clinical.pan[match(clinical$participant, clinical.pan$participant),]
clinical$pfi <- clinical.pan$PFI
clinical$pfi.time <- clinical.pan$PFI.time
clinical$dfi<- clinical.pan$DFI
clinical$dfi.time <- clinical.pan$DFI.time

write.table(clinical, file=output.filename, row.names=F, col.names=T, sep="\t")
