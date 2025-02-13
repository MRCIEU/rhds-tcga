#!/bin/bash

set -e

source config.env

mkdir -p $datadir
mkdir -p $resultsdir

url="https://gdac.broadinstitute.org/runs/stddata__2016_01_28/data/HNSC/20160128"

# for loop line by line in data/files.csv
# Skip the first line
{
    read
    while IFS=, read -r filename date time size
    do
        if [ ! -f $datadir/$filename ]; then
            echo "Downloading $filename from $url"
            curl -L $url/$filename -o $datadir/$filename

            echo "Downloading $filename.md5 from $url"
            curl -L $url/${filename}.md5 -o $datadir/${filename}.md5
        fi
    done
} < scripts/files.csv

# Navigate to the data directory
workdir=$(pwd)
cd $datadir

# Check md5sums
{
    read
    while IFS=, read -r filename date time size
    do
        md5sum -c ${filename}.md5
    done
} < $workdir/scripts/files.csv > ${resultsdir}/md5sums.txt

# Navigate back to the original directory
cd $workdir

