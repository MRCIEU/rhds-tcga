from dotenv import dotenv_values
import glob

config = dotenv_values("config.env")

datadir = config['datadir']
resultsdir = config['resultsdir']

rule all:
    input:
        f"{resultsdir}/md5sums.txt",
        "docs/clean-clinical.html",
        "docs/analysis.html"

rule download_data:
    "Download the omic data"
    input:
        "scripts/files.csv"
    output:
        f"{resultsdir}/md5sums.txt"
    log:
        f"{resultsdir}/logs/download-data.log"
    shell:
        "source scripts/download-data.sh"

rule download_pan_cancer_clinical:
    "Download the pan-cancer clinical data"
    output:
        f"{resultsdir}/TCGA-CDR-SupplementalTableS1.txt"
    log:
        f"{resultsdir}/logs/download-pan-cancer-clinical.log"
    shell:
        "Rscript scripts/download-pan-cancer-clinical.r"

rule extract_data:
    "Extract downloaded data and clean"
    input:
        expand(f"{resultsdir}/md5sums.txt", resultsdir=resultsdir)
    output:
        f"{resultsdir}/clinical.txt",
        f"{resultsdir}/protein-clean.txt",
        f"{resultsdir}/methylation-clean.txt"
    log:
        f"{resultsdir}/logs/extract-data.log"
    shell:
        "Rscript scripts/extract-data.r"

rule clean_clinical:
    "Clean clinical data"
    input:
        f"{resultsdir}/clinical.txt",
        f"{resultsdir}/TCGA-CDR-SupplementalTableS1.txt"
    output:
        "docs/clean-clinical.html"
    log:
        f"{resultsdir}/logs/clean-clinical.log"
    shell:
        "quarto render scripts/clean-clinical.qmd --output-dir ../docs"

rule predict_proteins:
    "Predict proteins from methylation data"
    input:
        f"{resultsdir}/methylation-clean.txt"
    output:
        f"{resultsdir}/predicted-proteins.txt"
    log:
        f"{resultsdir}/logs/predict-proteins.log"
    shell:
        "Rscript scripts/predict-proteins.r"

rule combine_data:
    "Combine clinical and predicted protein data"
    input:
        f"{resultsdir}/clinical-clean.txt",
        f"{resultsdir}/predicted-proteins.txt"
    output:
        f"{resultsdir}/combined-clin-pred-proteins.txt"
    log:
        f"{resultsdir}/logs/combine-data.log"
    shell:
        "Rscript scripts/combine.r"

rule analysis:
    "Analyze combined clinical and predicted protein data"
    input:
        f"{resultsdir}/combined-clin-pred-proteins.txt"
    output:
        "docs/analysis.html"
    log:
        f"{resultsdir}/logs/analysis.log"
    shell:
        "quarto render scripts/analysis.qmd --output-dir ../docs"


rule clean:
    "Clean up results directory"
    shell:
        """
        rm {resultsdir}/*
        """
