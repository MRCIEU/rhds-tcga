rule clean_clinical:
    "Clean clinical data"
    input:
        f"{resultsdir}/clinical.txt",
        f"{resultsdir}/TCGA-CDR-SupplementalTableS1.txt"
    output:
        f"{resultsdir}/clinical-clean.txt"
    container:
        "rhds-tcga-r.sif"
    log:
        f"{resultsdir}/logs/clean-clinical.log"
    shell:
        """
        Rscript scripts/clean-clinical.r
        """
