rule predict_proteins:
    "Predict proteins from methylation data"
    input:
        f"{datadir}/methylation-clean-score-sites.csv.gz"
    output:
        f"{resultsdir}/predicted-proteins.txt"
    container:
        "rhds-tcga-r.sif"
    log:
        f"{resultsdir}/logs/predict-proteins.log"
    shell:
        """
        Rscript scripts/predict-proteins.r {datadir} {resultsdir}
        """
