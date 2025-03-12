from dotenv import dotenv_values

myconfig = dotenv_values("config.env")

datadir = myconfig["datadir"]
resultsdir = myconfig["resultsdir"]
docsdir = myconfig["docsdir"]

onstart:
    print("running analysis pipeline")
    print(myconfig)

rule all:
    input:
        f"{resultsdir}/md5sums.txt",
        f"{docsdir}/analysis.html"

include: "rules/download-data.smk"
include: "rules/download-pan-cancer-clinical.smk"
include: "rules/extract-data.smk"
include: "rules/clean-clinical.smk"
include: "rules/predict-proteins.smk"
include: "rules/combine-data.smk"
include: "rules/analysis.smk"

rule clean:
    "Clean up output directories"
    shell:
        """
        rm {resultsdir}/*
        rm {docsdir}/*
        """
