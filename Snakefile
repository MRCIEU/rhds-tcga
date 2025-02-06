from dotenv import dotenv_values
import glob

config = dotenv_values("config.env")

datadir = config['datadir']
resultsdir = config['resultsdir']

rule all:
    input:
        "data/clinical-clean.html",
        "docs/analysis.html"

rule download_data:
    input:
        "scripts/files.csv"
    output:
        expand(f"{resultsdir}/md5checks.txt", resultsdir=resultsdir)
    shell:
        "source scripts/download-data.sh"

rule download_pan_cancer_clinical:
    output:
        f"{datadir}/TCGA-CDR-SupplementalTableS1.txt"
    shell:
        "Rscript scripts/download-pan-cancer-clinical.r"

rule extract_data:
    input:
        expand(f"{resultsdir}/md5checks.txt", resultsdir=resultsdir)
    output:
        f"{datadir}/clinical.txt",
        f"{datadir}/protein.txt",
        f"{datadir}/methylation.txt"
    shell:
        "Rscript scripts/extract-data.r"

rule clean_clinical:
    input:
        f"{datadir}/clinical.txt",
        f"{datadir}/TCGA-CDR-SupplementalTableS1.txt"
    output:
        "data/clinical-clean.html"
    shell:
        "R -e 'rmarkdown::render(\"docs/clean-clinical.rmd\", output_file=\"docs/clinical-clean.html\")'"

rule predict_proteins:
    input:
        f"{datadir}/methylation-clean.txt"
    output:
        f"{resultsdir}/predicted-proteins.txt"
    shell:
        "Rscript scripts/predict-proteins.r"

rule combine_data:
    input:
        f"{datadir}/clinical-clean.txt",
        f"{resultsdir}/predicted-proteins.txt"
    output:
        f"{resultsdir}/combined-clin-pred-proteins.txt"
    shell:
        "Rscript scripts/combine.r"

rule analysis:
    input:
        f"{resultsdir}/combined-clin-pred-proteins.txt"
    output:
        "docs/analysis.html"
    shell:
        "R -e 'rmarkdown::render(\"docs/analysis.rmd\", output_file=\"docs/analysis.html\")'"
