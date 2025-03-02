# Technical decisions for this implementation

## **Configuration**

Snakemake and user configuration parameters can be determined
on the command line or using a yaml file.
For example, the example below defines file paths used by the pipeline
and two parameters telling snakemake to
run rules inside apptainer containers and how to configure apptainer.

```
paths:
    data: &pathdata "/tmp/rhds-tcga-files/data"
    results: &pathresults "/tmp/rhds-tcga-files/results"
    docs: &pathdocs "/tmp/rhds-tcga-files/docs"

use-apptainer: True

apptainer-args: '--cwd /pipeline -B scripts:/pipeline/scripts -B *pathdata -B *pathresults -B *pathdocs'
```

The equivalent is possible from the command line:

```
snakemake --use-apptainer --apptainer-args "--cwd /pipeline ..." 
```

File paths used by the pipeline can be loaded directly
by the snakefile.

We chose to use the command-line option and pass the file paths using
.env files because:

1. Snakemake seemed to ignore the apptainer arguments in the yaml file
   but not when they were specified on the command line

2. yaml files tend to be far less flexible and system-independent
   than .env files (although yaml files can be easily parsed by R and Python
   scripts, but not by bash scripts) 

## Passing config variables to pipeline scripts

Pipeline configuration variables could be made available
to each pipeline script by having them load the .env config file.

However:

* This reduces pipeline transparency since every script does not need all
  configuration variables. 

* This reduces pipeline flexibility because the configuration filename
  is hard-coded in each script.

The improve transparency and flexibility,
the config file is passed as an argument to snakemake from the command-line
and only the configuration variables needed by each script
are passed as arguments to the script.

## Quarto outputs

The quarto argument `--output-dir` does not work as expected,
i.e. if it is set, quarto will not generate outputs to the specified
directory. There are dozens of discussions of this unexpected behavior
online.

Consequently, the snakemake rules simply move the files from the scripts
folder to the desired location.

Unfortunately, this creates a minor hiccup for apptainer containers
if the scripts folder is copied or cloned into the container image
when it is created.
Once the container image is created,
these files cannot change.
The solution is to instead bind the scripts folder
to the container at run time.
See, e.g. `-B scripts:/pipeline/scripts` in
[config/apptainer.env](config/apptainer.env).

Turns out that this also solves the problem that quarto opens 
qmd files in *write* mode!

## Container working directory is explicitly specified 

Apptainer binds the current working directory and user home directory
by default to the container.
The apptainer working directory is by default
the bound current working directory.
If this is not changed,
then R inside the container loads the external
rather than the internal renv environment.
The solution is to create a directory in the image
(here `/pileline`) to contain the renv files
and the scripts folder.


## Container image from apptainer definition rather than Dockerfile

Unfortunately docker is not available on Bristol HPC.
Although it is possible to work around this by creating
the docker image on another system, e.g. user laptop,
I found that, although everything worked as expected
in the docker image, renv hung in the
apptainer-converted image.
It seems to have something to do with how renv wants
to modify files in the container.
Docker containers allow container files to change
but Apptainer does not.
