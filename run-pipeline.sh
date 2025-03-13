#!/bin/bash

source config.env

mkdir -p ${datadir} ${resultsdir} ${docsdir}

echo "${snakemake_args[@]}"

set -x
snakemake "${snakemake_args[@]}"
set +x


