rule download_data:
    "Download the omic data"
    input:
        "scripts/files.csv"
    output:
        f"{resultsdir}/md5sums.txt"
    container:
        "rhds-tcga-r.sif"
    log:
        f"{resultsdir}/logs/download-data.log"
    shell:
        """
        bash scripts/download-data.sh {datadir} {resultsdir}
        """
