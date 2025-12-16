rule download_data:
    "Download the omic data"
    input:
        "scripts/files.csv"
    output:
        f"{resultsdir}/md5sums.txt",
        f"{datadir}/methylation-clean-score-sites.csv.gz"
    container:
        "rhds-tcga-r.sif"
    log:
        f"{resultsdir}/logs/download-data.log"
    shell:
        """
        cd scripts
        bash download-data.sh {datadir} {resultsdir} > {log}
        """
