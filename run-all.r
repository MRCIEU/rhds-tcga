#######
#######
# download-pan-cancer-clinical.r

library(readxl)
# url & filename for clinical outcome data from the PanCancer Atlas project 
# (https://gdc.cancer.gov/about-data/publications/pancanatlas)
url <- "https://api.gdc.cancer.gov/data/1b5f413e-a8d1-4d10-92eb-7c4ae739ed81"
filename <- "TCGA-CDR-SupplementalTableS1.xlsx"

cat("download-pan-cancer-clinical.r", filename, "\n")
if (!file.exists(filename))
{
	download.file(
		url,
		destfile=filename
	)
}

# save a tab-seperated vesion 
dat <- read_xlsx(filename, sheet=1)
write.table(
	dat,
	file=sub("xlsx$", "txt", filename), 
    sep="\t", row.names=F, col.names=T
)



#######
#######
# extract-data.r

## function for extracting tcga tar.gz's to named output
extract.file <- function(tar.file, extract.file, new.file){
    # get file path to extracted file
    x.file <- 
		grep(extract.file, 
			untar(tar.file, list = T),value = T)
	# extract the tar file
	cat("Extracting", tar.file, "to", new.file, "\n")
    untar(tar.file)

	# move the data to named output
    file.rename(x.file, new.file)
	
	# remove untared directory
	unlink(dirname(x.file), recursive = TRUE)
}

data.dir <- paths$data.dir 

#######################
## extract the clinical data
clinical.file <- file.path(data.dir, "clinical.txt")
if(!file.exists(clinical.file))
	extract.file( 
		tar.file = 
			file.path(data.dir,
				grep(".*_HNSC\\..*_Clinical\\.Level_1\\..*\\.tar\\.gz$", 
					list.files(data.dir), value = T)),
		extract.file = "HNSC.clin.merged.txt",
		new.file = clinical.file
		)


########################
## extract the protein data
protein.file <- file.path(data.dir, "protein.txt")
if(!file.exists(protein.file))
	extract.file( 
		tar.file = 
			file.path(data.dir,
				grep("*_protein_normalization__data.Level_3.*.tar.gz$", 
					list.files(data.dir), value = T)),
		extract.file = "data.txt",
		new.file = protein.file
		)
## clean protein output:
## 	- remove 2nd row
lines <- readLines(protein.file)[-2]
writeLines(lines, file.path(data.dir, "protein-clean.txt"))


########################
## extract the methylation data
methylation.file <- file.path(data.dir, "methylation.txt")
if(!file.exists(methylation.file))
	extract.file( 
		tar.file = 
			file.path(data.dir,
				grep(".*_HNSC\\..*_humanmethylation450_.*_data\\.Level_3\\..*\\.tar\\.gz$", 
					list.files(data.dir), value = T)),
		extract.file = "data.txt",
		new.file = methylation.file
		)
## clean methylation output:
awk_command <- "
	awk -F'\t' '{
	printf \"%s\t\", $1;
	for(i = 2; i <= NF; i += 4) {
		printf \"%s\t\", $i;
	}
	print \"\"
	}' methylation.txt | sed 2d  > methylation-clean.txt
	"

awk_command <- 
	paste(
		"awk -F'\t' '{
		printf \"%s\t\", $1;
		for(i = 2; i <= NF; i += 4) {
			printf \"%s\t\", $i;
		}
		print \"\"
		}'",
		methylation.file, 
		"| sed 2d  >",
		file.path(data.dir, "methylation-clean.txt"))

# Execute the command
system(awk_command)


#######
#######
# clean-clinical.r

clinical.filename <- file.path(paths$data.dir, "clinical.txt")
pan.cancer.filename <- file.path(paths$data.dir,
                        "TCGA-CDR-SupplementalTableS1.txt")
output.filename <- file.path(paths$data.dir, "clinical-clean.txt")

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


#######
#######
# predict-proteins.r

data.dir <- paths$data.dir
output.dir <- paths$output.dir
methylation.file <- file.path(data.dir, "methylation-clean.txt")

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
    index.na.row <- apply(data, 1, function(i) !all(is.na(i)))
    data <- data[index.na.row, ]

## check number of rows missing per sample
#miss <- apply(data, 2, function(i) table(is.na(i)), simplify=F)
#miss.df <- as.data.frame(do.call(rbind, miss))
#summary(miss.df$"TRUE")

## Before the all na row drop above ~90k observations
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#  89519   89566   89645   89790   89817   95558

library("IlluminaHumanMethylation450kanno.ilmn12.hg19")
library(meffonym)
## get gadd et all episcores models
models <- subset(meffonym.models(full=T), 
                grepl("^episcores", filename)) 

# get list of proteins to estimate
proteins <- models$name

# apply protein abundance coefs to dna methylation
pred.proteins <- sapply(
        proteins,
        function(model) {
            cat(date(), model, " ")
            ret <- meffonym.score(data, model)
            cat(" used ", length(ret$sites), "/", 
                length(ret$vars), "sites\n")
            ret$score
        })
rownames(pred.proteins) <- colnames(data)
pred.proteins <- scale(pred.proteins)
colnames(pred.proteins) <- make.names(colnames(pred.proteins))

## export results
my.write.table <- function(x, filename) {
    cat("saving", basename(filename), "...\n")
    write.table(x, file=filename, row.names=T, col.names=T, sep="\t")
}
my.write.table(pred.proteins, 
    file.path(output.dir, "predicted-proteins.txt"))


#######
#######
# combine.r

pred.protein.filename <- file.path(paths$output.dir, "predicted-proteins.txt")
clinical.filename <- file.path(paths$data.dir, "clinical-clean.txt")

output.dir <- paths$output.dir

## get helper functions for parsing tcga ids

## The format of sample identifiers/barcodes is described here:
## https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/
##
## Here is a summary:
## e.g. TCGA-3C-AAAU-01A-11D-A41Q-05
##   project TCGA
##   tissue source site 3C 
##   participant AAAU
##   sample 01 (01-09 tumor, 10-19 normal, 20-29 controls)
##   vial A
##   portion 11
##   analyte D (as in DNA)
##   plate A41Q
##   analysis center 05
##
## The following function extracts the participant identifier
## from a sample id/barcode.

extract.participant <- function(id) 
    sub("TCGA-[^-]+-([^-]+)-.*", "\\1", id)


extract.tissue <- function(id) {
    sub("TCGA-[^-]+-[^-]+-([0-9]+)[^-]+-.*", "\\1", id)
}

pred.proteins <- read.table(pred.protein.filename,
                        header=T,sep="\t",stringsAsFactors=F)

## extract participant tissue information 
tissues <- data.frame(
                participant = extract.participant(rownames(pred.proteins)),
                tissue = extract.tissue(rownames(pred.proteins)),
                participant.tissue = paste(extract.participant(rownames(pred.proteins)), 
                                        extract.tissue(rownames(pred.proteins)), sep = "-")
    )
tissues <- subset(tissues, tissue!= "06" & tissue!="V582")

## update pred.proteins to use participant.tissue rownames
samples <- rownames(pred.proteins)
rownames(pred.proteins) <- paste(extract.participant(samples), 
                                    extract.tissue(samples), sep = "-")

## get cleaned clinical data
clinical <- read.table(clinical.filename,
                        header=T,sep="\t",stringsAsFactors=F)

## combine with participant tissue info from predicted protein dataset
clinical <- merge(clinical, tissues, by.x = "participant")
clinical$tumor.or.normal <- ifelse(as.numeric(clinical$tissue) < 9, "tumor", "normal")
clinical$tumor <- sign(clinical$tumor.or.normal=="tumor")


table(rownames(pred.proteins) %in% clinical$participant.tissue)

## combine the clinical info with the methylation predicted protein abundances
out <- cbind(clinical, 
		pred.proteins[match(clinical$participant.tissue, rownames(pred.proteins)),])

## export results
my.write.table <- function(x, filename) {
    cat("saving", basename(filename), "...\n")
    write.table(x, file=filename, row.names=T, col.names=T, sep="\t")
}
my.write.table(out, 
    file.path(output.dir, "combined-clin-pred-proteins.txt"))

#######
#######
# analysis.r

## ----globals -------------------------------------------------------------
library(ggplot2)
library(ggrepel)

## ----load.data -------------------------------------------------------------
combined.filename <- file.path(paths$output.dir, "combined-clin-pred-proteins.txt")
data <- read.table(combined.filename,
                        header=T,sep="\t",stringsAsFactors=F)

## ----names -------------------------------------------------------------
## get predicted protein names
protein.names <- 
	subset(meffonym::meffonym.models(full=T), 
		grepl("^episcores", filename))$name
protein.names <- make.names(protein.names)

table(protein.names %in% colnames(data))
##TRUE 
## 109 

## ----tissue -------------------------------------------------------------

## define glm formulae with pred.proteins as predictors of 'tumor.or.normal'
## tissue i.e. tumor.or.normal ~ pred.protein
formulae <- sapply(protein.names, function(i){
		reformulate(i, response = "tumor")
		}, simplify = F)

# run glms 
fit <- sapply(formulae, function(i){
	glm(i, data = data, family = binomial())
	}, simplify = F)

fit.summary <- sapply(fit ,function(i){
	out <- summary(i)$coefficients
	out[,"Estimate"] <- out[,"Estimate"]
	out
	}, simplify = F)

fit.coefs <- sapply(fit.summary, function(i){
	i[2, c("Estimate", "Pr(>|z|)")]
	}, simplify = F) 
fit.coefs <- {
	x <- do.call(rbind, fit.coefs)
	data.frame(
		pred.protein = rownames(x),
		coef = x[, "Estimate"],
		p.value = x[, "Pr(>|z|)"]
	)
}

bonferroni <- -log10(0.05/length(fit))

## ----tissue.figs -------------------------------------------------------------
fit.coefs |>
	ggplot(aes(x = pred.protein, y = -log10(p.value))) +
		geom_point()+ 
		theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
		geom_text_repel(
			data = fit.coefs[which((-log10(fit.coefs$p.value) > bonferroni)), ], 
		    	aes(x=pred.protein,y=-log10(p.value),label=pred.protein))+ 
		geom_hline(yintercept = bonferroni, 
			linetype='dashed')

fit.coefs |>
		ggplot(aes(x = coef, y = -log10(p.value))) +
		geom_point()+
		geom_text_repel(
			data = fit.coefs[which((-log10(fit.coefs$p.value) > bonferroni)), ], 
		    	aes(x=coef,y=-log10(p.value),label=pred.protein))+ 
		geom_hline(yintercept = bonferroni, 
			linetype='dashed')


## ----pfi -------------------------------------------------------------
tumor.data <- subset(data, tumor ==1)

## define glm formulae with pred.proteins as predictors of pfi
## tissue i.e. pfi ~ pred.protein
formulae <- sapply(protein.names, function(i){
		reformulate(i, response = "pfi")
		}, simplify = F)

# run glms 
fit <- sapply(formulae, function(i){
	glm(i, data = tumor.data, family = binomial())
	}, simplify = F)

fit.summary <- sapply(fit ,function(i){
	out <- summary(i)$coefficients
	out[,"Estimate"] <- out[,"Estimate"]
	out
	}, simplify = F)

fit.coefs <- sapply(fit.summary, function(i){
	i[2, c("Estimate", "Pr(>|z|)")]
	}, simplify = F) 
fit.coefs <- {
	x <- do.call(rbind, fit.coefs)
	data.frame(
		pred.protein = rownames(x),
		coef = x[, "Estimate"],
		p.value = x[, "Pr(>|z|)"]
	)
}

## ----pfi.figs -------------------------------------------------------------
fit.coefs |>
	ggplot(aes(x = pred.protein, y = -log10(p.value))) +
		geom_point()+ 
		theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
		geom_text_repel(
			data = fit.coefs[which((-log10(fit.coefs$p.value) > bonferroni)), ], 
		    	aes(x=pred.protein,y=-log10(p.value),label=pred.protein))+ 
		geom_hline(yintercept = bonferroni, 
			linetype='dashed')

fit.coefs |>
		ggplot(aes(x = coef, y = -log10(p.value))) +
		geom_point()+
		geom_text_repel(
			data = fit.coefs[which((-log10(fit.coefs$p.value) > bonferroni)), ], 
		    	aes(x=coef,y=-log10(p.value),label=pred.protein))+ 
		geom_hline(yintercept = bonferroni, 
			linetype='dashed')
