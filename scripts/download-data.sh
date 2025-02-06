#!/bin/bash

source config.env

mkdir -p $datadir/tcga

url="https://gdac.broadinstitute.org/runs/stddata__2016_01_28/data/HNSC/20160128"

# for loop line by line in data/files.csv
while IFS=, read -r filename date time size
do
    echo "Downloading $filename from $url"
    # curl -s -L $url/$filename -o $datadir/tcga/$filename
    curl -s -L $url/${filename}.md5 -o $datadir/tcga/${filename}.md5
    echo "Checking MD5"
    # md5sum -c $datadir/tcga/${filename}.md5
done < files.csv
