rule predict_proteins:
    "Predict proteins from methylation data"
    input:
        f"{resultsdir}/methylation-clean.txt"
    output:
        f"{resultsdir}/predicted-proteins.txt"
    container:
        "rhds-tcga-r.sif"
    log:
        f"{resultsdir}/logs/predict-proteins.log"
    shell:
        """
        Rscript scripts/predict-proteins.r
        """
