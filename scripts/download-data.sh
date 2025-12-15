#!/bin/bash

set -e ## exit immediately if a command exits with a non-zero status

datadir=$1
resultsdir=$2

mkdir -p $datadir
mkdir -p $resultsdir

# for loop line by line in data/files.csv
# Skip the first line
{
    read
    while IFS=, read -r url filename date time size
    do
        if [ ! -f $datadir/$filename ]; then
            echo "Downloading $filename from $url"
            curl -L $url/$filename -o $datadir/$filename

            echo "Downloading $filename.md5 from $url"
            curl -L $url/${filename}.md5 -o $datadir/${filename}.md5
        fi
    done
} < files.csv

# Navigate to the data directory
workdir=$(pwd)
cd $datadir


# Check md5sums
echo "" > ${resultsdir}/md5sums.txt
{
    read
    while IFS=, read -r url filename date time size
    do
        echo "Verifying md5sum for $filename"
        md5sum -c ${filename}.md5 >> ${resultsdir}/md5sums.txt
    done
} < $workdir/files.csv

# Navigate back to the original directory
cd $workdir
