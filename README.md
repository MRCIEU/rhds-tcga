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

### If modules are available

```
module load languages/python/3.12.3
module load apptainer/1.3.6
```

### If any modules are not available

Ensure that [mamba](README-mamba.md) is installed.

Create a mamba environment for the pipeline.

```
mamba create --name "rhds" python=3.12.8
mamba activate rhds
```

Install apptainer:

```
mamba install conda-forge::apptainer=1.3.6
```

## Build the container image

```
apptainer build rhds-tcga-r.sif rhds-tcga-r.def
``

## Running the pipeline commands in containers

Any individual [pipeline command](README-description.md),
can be run via apptainer, e.g. we can run
`quarto render scripts/analysis.qmd` as follows:

```
source config.env
mkdir -p ${datadir} ${resultsdir} ${docsdir}
apptainer run \
    --fakeroot \
    -B scripts:/pipeline/scripts \
    -B config.env:/pipeline/config.env \
    -B ${datadir} -B ${resultsdir} -B ${docsdir} \
    rhds-tcga-r.sif \
    quarto render scripts/analysis.qmd
```


