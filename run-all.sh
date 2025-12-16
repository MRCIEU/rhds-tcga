#!/bin/bash

set -e

source config.env

cd scripts
bash download-data.sh $datadir $resultsdir
Rscript download-pan-cancer-clinical.r $datadir $resultsdir
Rscript extract-data.r $datadir $resultsdir
Rscript clean-clinical.r $resultsdir
Rscript predict-proteins.r $datadir $resultsdir
Rscript combine.r $resultsdir
quarto render analysis.qmd -P resultsdir:$resultsdir --output-dir ../docs

