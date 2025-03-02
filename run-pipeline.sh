#!/bin/bash

CONFIGENV="config/default.env"

if [[ $# -gt 0 ]]; then
    CONFIGENV=$1
fi

source $CONFIGENV

set -x
snakemake --config CONFIGENV=$CONFIGENV "${SNAKEMAKE_ARGS[@]}"
set +x


