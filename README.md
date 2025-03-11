# Prediction of cancer progression from imputed proteomics

This pipeline uses clinical and DNA methylation data
from head and neck squamous cell carcinomas (HNSCCs)
in The Cancer Genome Atlas (TCGA) to predict disease progression.

Individual steps and outputs of the pipeline are described [here](README-description.md).

## Pipeline configuration

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

### Install mamba

Ensure that [mamba](README-mamba.md) is installed.

### Install snakemake

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
[these steps](README-renv.md).

### Install pipeline dependencies: container option

Alternatively, the analyses can be run from within a container,
e.g. using Apptainer.

Create an Apptainer image file `rhds-tcga-r.sif` as follows:

```
apptainer build rhds-tcga-r.sif rhds-tcga-r.def
```

### Install pipeline dependencies: modules option

On a system with python and apptainer modules, load them as follows:

```
module load languages/python/3.12.3
module load apptainer/1.3.6
```

Snakemake and the `dotenv` python package can be installed 
by pip.

```
pip3 install snakemake==8.28.0
pip3 install dotenv==0.9.9
...
```

## Running the pipeline

Run the pipeline **without** containers:

```
snakemake
```

Run the pipeline **with** containers:

```
source config.env

snakemake \
    --use-apptainer \
    --apptainer-args "--cwd /pipeline -B scripts:/pipeline/scripts -B ${DATADIR} -B ${RESULTSDIR} -B ${DOCSDIR}"
```

Run the pipeline *with* containers using a script
(assumes that `config.env` specifies required apptainer arguments):

```bash
bash run-pipeline.sh 
```

## Pipeline implementation explanations

A discussion of pipeline implementation decisions
can be found [here](README-decisions.md). 

