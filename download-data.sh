#!/bin/bash

set -e

url="https://gdac.broadinstitute.org/runs/stddata__2016_01_28/data/HNSC/20160128"

# for loop line by line in data/files.csv
# Skip the first line
{
    read
    while IFS=, read -r filename date time size
    do
        echo "Downloading $filename from $url"
        curl -s -L $url/$filename
    done
} < files.csv
