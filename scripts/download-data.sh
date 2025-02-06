#!/bin/bash

set -e

source config.env

mkdir -p $datadir/tcga

url="https://gdac.broadinstitute.org/runs/stddata__2016_01_28/data/HNSC/20160128"

# for loop line by line in data/files.csv
# Skip the first line
{
    read
    while IFS=, read -r filename date time size
    do
        echo "Downloading $filename from $url"
        curl -s -L $url/$filename -o $datadir/tcga/$filename

        echo "Downloading $filename.md5 from $url"
        curl -s -L $url/${filename}.md5 -o $datadir/tcga/${filename}.md5
    done
} < files.csv

# Navigate to the data directory
workdir=$(pwd)
cd $datadir/tcga

# Check md5sums
{
    read
    while IFS=, read -r filename date time size
    do
        md5sum -c ${filename}.md5
    done
} < $workdir/files.csv

# Navigate back to the original directory
cd $workdir

