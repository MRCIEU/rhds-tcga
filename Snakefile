datadir = config['paths']['data']
resultsdir = config['paths']['results']
docsdir = config['paths']['docs']

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
