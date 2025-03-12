#!/bin/bash

source config.env

mkdir -p ${datadir} ${resultsdir} ${docsdir}

set -x
snakemake "${snakemake_args[@]}"
set +x


