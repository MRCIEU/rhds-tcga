rule extract_data:
    "Extract downloaded data and clean"
    input:
        f"{resultsdir}/md5sums.txt"
    output:
        f"{resultsdir}/clinical.txt",
        f"{resultsdir}/protein-clean.txt",
        f"{resultsdir}/methylation-clean.txt"
    container:
        "rhds-tcga-r.sif"
    log:
        f"{resultsdir}/logs/extract-data.log"
    shell:
        """
        Rscript scripts/extract-data.r
        """
