#!/bin/bash

source config.env

mkdir -p ${datadir} ${resultsdir} ${docsdir}

set -x
snakemake "${SNAKEMAKE_ARGS[@]}"
set +x


