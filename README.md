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

### Install pipeline dependencies: mamba option

Ensure that [mamba](README-mamba.md) is installed.

Create a mamba environment for the pipeline.

```
mamba create --name "rhds" python=3.12.8
mamba activate rhds
```

Install snakemake.

```
pip3 install snakemake==8.28.0
pip3 install dotenv==0.9.9
```

If it is not already installed, R can be installed as well:

```
mamba install conda-forge::r-base=4.4.1
```

Start R and install R packages using the
renv lock file [renv.lock](renv.lock).

```R
renv::restore()
```

For reference, the lock file was created using
[these steps](README-renv.md).

### Install pipeline dependencies: container option

Alternatively, the rules can be executed from within a container,
e.g. using Apptainer.

With this option, you'll still need
apptainer, python and snakemake installed.
These can be installed using mamba described above, or,
if you using an HPC system, they may be available as modules.

If installing using mamba:

```
mamba create --name "rhds" python=3.12.8
mamba activate rhds
mamba install conda-forge::apptainer=1.3.6
```

If available as modules:

```
module load languages/python/3.12.3
module load apptainer/1.3.6
```

Snakemake and the `dotenv` python package can be installed using pip:

```
pip3 install snakemake==8.28.0
pip3 install dotenv==0.9.9
```

If it hasn't been already,
the container image can be built as follows:

```
apptainer build rhds-tcga-r.sif rhds-tcga-r.def
``

## Running the pipeline

Run the pipeline **without** containers:

```
snakemake
```

Run the pipeline **with** containers:

```
source config.env
mkdir -p ${docsdir} ${resultsdir} ${datadir}
snakemake \
    --use-apptainer \
    --apptainer-args "--fakeroot --cwd /pipeline -B scripts:/pipeline/scripts -B config.env:/pipeline/config.env -B ${datadir} -B ${resultsdir} -B ${docsdir}"
```

Run the pipeline *with* containers using a script
(assumes that `config.env` specifies required apptainer arguments):

```bash
bash run-pipeline.sh 
```

## Pipeline implementation explanations

A discussion of pipeline implementation decisions
can be found [here](README-decisions.md). 

