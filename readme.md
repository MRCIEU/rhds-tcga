# Prediction of cancer progression from imputed proteomics

## Setup

Create a `config/settings.yml` file based on `config/template.yml` that
will at least have the following variables:

```
paths:
    data: '/PATH/TO/DATA/DIR'
    results: '/PATH/TO/RESULTS/DIR'
    docs: '/PATH/TO/DOCS/DIR'
```

The data directory is for raw downloaded data that ideally you won't modify.

The results directory is for intermediate steps and final results.

The docs directory is for reports describing results. 

Example config files can be found in `config/`
for a mamba-based installation ([config/mamba.yml](config/mamba.yml)
and for a container-based installation ([config/apptainer.yml](config/apptainer.yml)).

All files in the results and docs directories should be reproducible.

## Installation

### Install mamba

Ensure that [mamba](readme-mamba.md) is installed.

### Install snakemake

Create a mamba environment for the pipeline.

```
mamba create --name "rhds-tcga" python=3.12.8
mamba activate rhds-tcga
```

Install snakemake.

```
pip3 install snakemake==8.28.0
```

### Install pipeline dependencies: mamba option

If it is not already installed, R can be installed using mamba:

```
mamba install conda-forge::r-base=4.4.2
```

Start R and install R packages using the
renv lock file [renv.lock](renv.lock).

```R
renv::restore()
```

For reference, the lock file was created using
[these steps](readme-renv.md).

### Install pipeline dependencies: container option

Alternatively, the analyses can be run from within a container,
e.g. using Apptainer. 
Create an apptainer image as follows:

```
apptainer build rhds-tcga-r.sif rhds-tcga-r.def
```

*It is possible to start a shell prompt in the container by running the following:*

```
apptainer shell -B /tmp/rhds-tcga-files -B scripts:/pipeline/scripts rhds-tcga-r.sif
```

### Install pipeline dependencies: cluster option

<mark>TO BE COMPLETED</mark>

```
module load languages/python/3.12.3
module load apptainer/1.1.9 ## or 1.3.1
pip3 install snakemake==8.28.0
...
```


## Running the pipeline

Run the pipeline using Snakemake replacing the configuration
file with the config file created for your installation.

```bash
snakemake --configfile=config/mamba.yml all
```

<mark>Apptainer arguments ignored in the config file??</mark>

```
snakemake --configfile=config/apptainer.yml --use-apptainer all
## --use-apptainer --apptainer-args "--cwd /pipeline -B /tmp/rhds-tcga-files/ -B scripts:/pipeline/scripts" all
```

## Pipeline description

Individual steps in the pipeline are described below.

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

### Extract tcga data and clean clinical phenotypes

The datasets will be generated
from the downloaded files to the `data` directory
using the following script.

```
Rscript scripts/extract-data.r
```

Final clinical phenotype cleaning is also performed

```
quarto render scripts/clean-clinical.qmd --output-dir docs
```

### DNA methylation predicted protein abundances

Estimate 109 predicted protein levels using DNA methylation data
using the prediction models developed by Gadd et al. 2022 and 
implemented in meffonym R package (https://github.com/perishky/meffonym):

> Gadd et al., ‘Epigenetic Scores for the Circulating Proteome as Tools for 
> Disease Prediction’. Elife. 2022. doi: 10.7554/ELIFE.71802

```
Rscript scripts/predict-proteins.r
```

These results are combine with clincal phenotyping data into
a final analysis ready dataset

```
Rscript scripts/combine.r
```

### Example analysis 

There are two example analyses performed in `scripts/analysis.qmd` and 
summarized in the `docs/analysis.html` report.

```
quarto render scripts/analysis.qmd --output-dir docs
```

1. The methylation dataset has observations performed on both tumor and 
adjacent normal tissues. The first analysis looks at the association between
DNA methylation predicted protein abundances and tissue type (tumor vs. normal)

2. Progression free interval (PFI) is a measure of cancer progression. This
analysis restricts to DNA methylation predicted protein abundances from tumor
cells and looks at association with PFI.
