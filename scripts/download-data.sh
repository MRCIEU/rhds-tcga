#!/bin/bash

datadir=$1
resultsdir=$2

set -e ## exit immediately if a command exits with a non-zero status

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


# download cleaned dnam data
url="https://raw.githubusercontent.com/MRCIEU/rhds-admin/refs/heads/main/data/results/methylation-clean-score-sites.csv?token=GHSAT0AAAAAADOYU5BIH67U54RSM4NYDDDI2J73EXA"
curl -L $url -o $datadir/methylation-clean-score-sites.csv

url="https://raw.githubusercontent.com/MRCIEU/rhds-admin/refs/heads/main/data/results/methylation-clean-score-sites.csv.md5?token=GHSAT0AAAAAADOYU5BJP726XYMN6H5XQX7Y2J725MQ"
curl -L $url -o $datadir/methylation-clean-score-sites.csv.md5
