# rhds-tcga


## Installation

We will use mamba to manage software dependencies.

```
mamba env create -f requirements.yml
```

Note - on Apple ARM processors run

```
CONDA_SUBDIR=osx-64 mamba env create -f requirements.yml
```

Following installation of the CRAN and Bioconductor packages you will have to install the `meffonym` package from GitHub:

```r
remotes::install_github("perishky/meffonym")
```


## run-all.r

The `run-all.r` script coordinates all analysis in this repo. It can
be run in batch mode (shown below) or by iterating through each step
via an interactive R session

```
Rscript run-all.r
```

## tcga pipeline steps

### install-packages.r

To successfully download the TCGA data and run the pipeline 
you'll need to have the R statistical programming language installed.
Additionally, a few R packages must be installed prior to implementing the 
pipeline. To install these, run the below command:

```
source("install-packages.r",echo=T)
```

### download-data.r: downloading and preparing the dataset

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
system(paste("Rscript download-data.r", "files.csv", paths$data.dir))
```

### download-pan-cancer-clinical.r: downloading PanCancer Atlas clinical info

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
source("download-pan-cancer-clinical.r",echo=T)
```

### extract tcga data and clean clinical phenotypes

The datasets will be generated
from the downloaded files to the `data` directory
using the following script.

```
source("extract-data.r",echo=T)
```

Final clinical phenotype cleaning is also performed

```
source("clean-clinical.r",echo=T)
```


### DNA methylation predicted protein abundances

Estimate 109 predicted protein levels using DNA methylation data
using the prediction models developed by Gadd et al. 2022 and 
implemented in meffonym R package (https://github.com/perishky/meffonym):

> Gadd et al., ‘Epigenetic Scores for the Circulating Proteome as Tools for 
> Disease Prediction’. Elife. 2022. doi: 10.7554/ELIFE.71802

```
source("predict-proteins.r",echo=T)
```

These results are combine with clincal phenotyping data into
a final analysis ready dataset

```
source("combine.r",echo=T)
```

### Example analysis 

There are two example analyses performed in `analysis.rmd` and 
summarized in the `analysis.html` report.

```
render("analysis.rmd", 
	output_format = "all")
```

1. The methylation dataset has observations performed on both tumor and 
adjacent normal tissues. The first analysis looks at the association between
DNA methylation predicted protein abundances and tissue type (tumor vs. normal)

2. Progression free interval (PFI) is a measure of cancer progression. This
analysis restricts to DNA methylation predicted protein abundances from tumor
cells and looks at association with PFI. 

