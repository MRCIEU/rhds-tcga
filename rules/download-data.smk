rule download_data:
    "Download the omic data"
    input:
        "scripts/files.csv"
    output:
        f"{resultsdir}/md5sums.txt"
    log:
        f"{resultsdir}/logs/download-data.log"
    shell:
        "source scripts/download-data.sh {datadir} {resultsdir}"
