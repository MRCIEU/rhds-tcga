rule combine_data:
    "Combine clinical and predicted protein data"
    input:
        f"{resultsdir}/clinical-clean.txt",
        f"{resultsdir}/predicted-proteins.txt"
    output:
        f"{resultsdir}/combined-clin-pred-proteins.txt"
    container:
        "rhds-tcga-r.sif"
    log:
        f"{resultsdir}/logs/combine-data.log"
    shell:
        """
        Rscript scripts/combine.r {resultsdir}
        """
