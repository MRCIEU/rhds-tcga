# Prediction of cancer progression from imputed proteomics

## Installation

To run the analysis you need R packages installed:

```r
install.packages("here")
install.packages("readxl")
```

## Pipeline

Individual steps are described below.

### Downloading and preparing the dataset

Available TCGA data collection on HNSC is well summarized here:
https://gdac.broadinstitute.org/runs/stddata__2016_01_28/samples_report/HNSC.html

Compiled a list of files to download from the GDAC website:
http://gdac.broadinstitute.org/runs/stddata__2016_01_28/data/HNSC/20160128
See `files.csv` in this directory.

The pipeline assumes a typical rdsf directory structure, with this repo
cloned under scripts:

```
├── data
├── results
└── scripts
    └── rhds-tcga
```

Data files will be downloaded to the `data` directory by using the 
below command:

```
bash scripts/download-data.sh
```

### Downloading PanCancer Atlas clinical info

Clinical outcome data has been cleaned up as part of the
PanCancer Atlas project
(https://gdc.cancer.gov/about-data/publications/pancanatlas).

> Liu J, Lichtenberg T, Hoadley KA, et al. An Integrated TCGA Pan-Cancer
> Clinical Data Resource to Drive High-Quality Survival Outcome
> Analytics. Cell. 2018;173(2):400-416.e11. doi:10.1016/j.cell.2018.02.052

This publication cautions against using overall survival as an outcome
because the follow-up isn't long enough.
Recommends progression-free interval (PFI) or
disease-free interval (DFI).
PFI and DFI are available in Supplementary Table 1
(https://api.gdc.cancer.gov/data/1b5f413e-a8d1-4d10-92eb-7c4ae739ed81).
The table is downloaded to the `data` directory
using the following script.

```
Rscript scripts/download-pan-cancer-clinical.r
```
