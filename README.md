# Prediction of cancer progression from imputed proteomics

This pipeline uses clinical and DNA methylation data
from head and neck squamous cell carcinomas (HNSCCs)
in The Cancer Genome Atlas (TCGA) to predict disease progression.

Individual steps and outputs of the pipeline are described [here](README-description.md).

Here we show how to containerize individual components on
the pipeline.

## Configuration

Create a `config.env` file based on
[config-template.env](config-template.env) that
will at least have the following variables:

```
datadir="/PATH/TO/DATA/DIR"
resultsdir="/PATH/TO/RESULTS/DIR"
docsdir="/PATH/TO/DOCS/DIR"
```

* The data directory is for raw downloaded data that ideally you won't modify.

* The results directory is for intermediate steps and final results.

* The docs directory is for reports describing results. 

*All files in the results and docs directories should be reproducible.*

## Pipeline installation

### If apptainer is available as a module

```
module load apptainer/1.3.6
```

### If apptainer needs to be installed

Ensure that [mamba](README-mamba.md) is installed.

Create a mamba environment for the pipeline, 
then load the environment and install apptainer. 

```
mamba install conda-forge::apptainer=1.3.6
```


## Build the container image

```
apptainer build rhds-tcga-r.sif rhds-tcga-r.def
```

> If the build fails on your system and you don't have time to figure out why,
> it can be downloaded:

```
wget https://zenodo.org/records/15011337/files/rhds-tcga-r.sif?download=1 -O rhds-tcga-r.sif
```

## Running the pipeline commands in containers

Any individual [pipeline command](README-description.md),
can be run via apptainer, e.g.
below we run all the steps in the pipeline
within our container:

```
source config.env
mkdir -p ${datadir} ${resultsdir} ${docsdir}

apptainer run \
    --fakeroot \
    -B $(pwd) \
    -B ${datadir} -B ${resultsdir} -B ${docsdir} \
    rhds-tcga-r.sif \
    bash scripts/download-data.sh

apptainer run \
    --fakeroot \
    -B $(pwd) \
    -B ${datadir} -B ${resultsdir} -B ${docsdir} \
    rhds-tcga-r.sif \
    Rscript scripts/download-pan-cancer-clinical.r

apptainer run \
    --fakeroot \
    -B $(pwd) \
    -B ${datadir} -B ${resultsdir} -B ${docsdir} \
    rhds-tcga-r.sif \
    Rscript scripts/extract-data.r

apptainer run \
    --fakeroot \
    -B $(pwd) \
    -B ${datadir} -B ${resultsdir} -B ${docsdir} \
    rhds-tcga-r.sif \
    Rscript scripts/clean-clinical.r


apptainer run \
    --fakeroot \
    -B $(pwd) \
    -B ${datadir} -B ${resultsdir} -B ${docsdir} \
    rhds-tcga-r.sif \
    Rscript scripts/predict-proteins.r


apptainer run \
    --fakeroot \
    -B $(pwd) \
    -B ${datadir} -B ${resultsdir} -B ${docsdir} \
    rhds-tcga-r.sif \
    Rscript scripts/combine.r

apptainer run \
    --fakeroot \
    -B $(pwd) \
    -B ${datadir} -B ${resultsdir} -B ${docsdir} \
    rhds-tcga-r.sif \
    quarto render scripts/analysis.qmd
```

> **Note:** on some systems `--fakeroot` may generate an
> error. The error message would say something like
> "FATAL:   --fakeroot used without sandbox image or user namespaces".
> This can be resolved by omitting the `--fakeroot` option.
