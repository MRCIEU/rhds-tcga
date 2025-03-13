#!/bin/bash

set -e

if [ -z "${MY_GITHUB_URL}" ]; then
    echo "Please set MY_GITHUB_URL before proceeding"
    exit 1;
fi

# create relevant directories

mkdir -p ${WORK}/data/rhds/data
mkdir -p ${WORK}/data/rhds/results

# Get the relevant results file
wget -O ${WORK}/data/rhds/results/combined-clin-pred-proteins.txt https://raw.githubusercontent.com/MRCIEU/rhds-tcga/refs/heads/raw/combined-clin-pred-proteins.txt

# Get the relevant scripts
if [ -d ~/rhds_template ]; then
    echo "exists"
    rm -rf ~/rhds_template
fi
git clone https://github.com/explodecomputer/rhds ~/rhds_template

cd ~/rhds_template

# Update my github repo with these scripts
git remote set-url origin $MY_GITHUB_URL
git push -f

# Create new config files
> config.env
echo "datadir=\"$(realpath $WORK/data/rhds/data)\"" >> config.env
echo "resultsdir=\"$(realpath $WORK/data/rhds/results)\"" >> config.env

# Install the R packages
Rscript -e "install.packages('renv'); renv::restore()"

# Check that it works
Rscript scripts/analysis.r
