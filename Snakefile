from dotenv import dotenv_values

myconfig = dotenv_values(config["CONFIGENV"])

datadir = myconfig["DATADIR"]
resultsdir = myconfig["RESULTSDIR"]
docsdir = myconfig["DOCSDIR"]

onstart:
    print("running analysis pipeline")
    print(f"config file = {config['CONFIGENV']}")
    print(myconfig)

rule all:
    input:
        f"{resultsdir}/md5sums.txt",
        f"{docsdir}/clean-clinical.html",
        f"{docsdir}/analysis.html"

include: "rules/download-data.smk"
include: "rules/download-pan-cancer-clinical.smk"
include: "rules/extract-data.smk"
include: "rules/clean-clinical.smk"
include: "rules/predict-proteins.smk"
include: "rules/combine-data.smk"
include: "rules/analysis.smk"

rule clean:
    "Clean up results directory"
    shell:
        """
        rm {resultsdir}/*
        """
