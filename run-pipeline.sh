#!/bin/bash

source config.env

set -x
snakemake "${SNAKEMAKE_ARGS[@]}"
set +x


