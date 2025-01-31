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


#######################
## extract the clinical data
clinical.file <- "clinical.txt"
if(!file.exists(clinical.file))
	extract.file( 
		tar.file = grep(".*_HNSC\\..*_Clinical\\.Level_1\\..*\\.tar\\.gz$", 
					list.files(), value = T),
		extract.file = "HNSC.clin.merged.txt",
		new.file = clinical.file
		)


########################
## extract the protein data
protein.file <- "protein.txt"
if(!file.exists(protein.file))
	extract.file( 
		tar.file = grep("*_protein_normalization__data.Level_3.*.tar.gz", 
					list.files(), value = T),
		extract.file = "data.txt",
		new.file = protein.file
		)
## clean protein output:
## 	- remove 2nd row
lines <- readLines(protein.file)[-2]
writeLines(lines, "protein-clean.txt")


########################
## extract the methylation data
methylation.file <- "methylation.txt"
if(!file.exists(methylation.file))
	extract.file( 
		tar.file = grep(".*_HNSC\\..*_humanmethylation450_.*_data\\.Level_3\\..*\\.tar\\.gz$", 
					list.files(), value = T),
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
# Execute the command
system(awk_command)

## alternative by reading into r
## 	- remove 2nd row
lines <- readLines(methylation.file)[-2]
writeLines(lines, methylation.file)

## - extract relevant columns
library(data.table)
data <- as.data.frame(fread(methylation.file, 
			sep = "\t", 
			header = FALSE,
			stringsAsFactors = FALSE))

# Select columns: Keep column 1, then every 4th column starting from column 2
selected_cols <- c(1, seq(2, ncol(data), by = 4))
fwrite(data[, selected_cols],
	file="methylation-clean.txt",
	sep="\t",row.names=F,col.names=F)



