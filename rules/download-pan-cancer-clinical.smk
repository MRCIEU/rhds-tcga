rule download_pan_cancer_clinical:
    "Download the pan-cancer clinical data"
    output:
        f"{resultsdir}/TCGA-CDR-SupplementalTableS1.txt"
    container:
        "rhds-tcga-r.sif"
    log:
        f"{resultsdir}/logs/download-pan-cancer-clinical.log"
    shell:
        "Rscript scripts/download-pan-cancer-clinical.r {datadir} {resultsdir}"
