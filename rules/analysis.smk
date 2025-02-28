rule analysis:
    "Analyze combined clinical and predicted protein data"
    input:
        f"{resultsdir}/combined-clin-pred-proteins.txt"
    output:
        f"{docsdir}/analysis.html"
    container:
        "rhds-tcga-r.sif"
    log:
        f"{resultsdir}/logs/analysis.log"
    shell:
        """
        quarto render scripts/analysis.qmd \
            -P resultsdir:"{resultsdir}"
        mv scripts/analysis.html scripts/analysis_files {docsdir}
        """
