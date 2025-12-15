# Prediction of cancer progression from imputed proteomics

This pipeline uses clinical and DNA methylation data
from head and neck squamous cell carcinomas (HNSCCs)
in The Cancer Genome Atlas (TCGA) to predict disease progression.

Individual steps and outputs of the pipeline are described [here](readme-description.md).

## Setup

Create a `config.env` file based on
[config-template.env](config-template.env) that
will at least have the following variables:

```
datadir="/PATH/TO/DATA/DIR"
resultsdir="/PATH/TO/RESULTS/DIR"
docsdir="/PATH/TO/DOCS/DIR"

snakemake_args=(--cores 1 --use-apptainer --apptainer-args "--fakeroot -B ${datadir} -B ${resultsdir} -B ${docsdir} -B $(pwd)")
```

* The data directory is for raw downloaded data that ideally you won't modify (e.g. /data/<username>/data)

* The results directory is for intermediate steps and final results (e.g. /data/<username>/results)

* The docs directory is for reports describing results (e.g. /data/<username>/docs)

*All files in the results and docs directories should be reproducible.*

## Installation

### Install mamba

Ensure that [mamba](readme-mamba.md) is installed.

### Install external dependencies

Create a mamba environment for the pipeline.

```
mamba create --name "rhds-tcga" python=3.12.8
mamba activate rhds-tcga
```

Install snakemake.

```
pip3 install snakemake==8.28.0
pip3 install dotenv==0.9.9
```

## Create container image

Create an Apptainer image file `rhds-tcga-r.sif` as follows:

```
apptainer build rhds-tcga-r.sif rhds-tcga-r.def
```

## Running the pipeline

Run the pipeline using a script that
assembles a snakemake command and executes it.

```bash
bash run-pipeline.sh
```

A discussion of pipeline implementation decisions
can be found [here](readme-decisions.md). 

