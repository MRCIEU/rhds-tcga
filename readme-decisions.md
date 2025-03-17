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

apptainer-args: "--fakeroot -B *pathdata -B *pathresults -B *pathdocs -B $(pwd)"
```

The equivalent is possible from the command line:

```
snakemake --use-apptainer --apptainer-args "--fakeroot ..."
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
the config file is loaded by snakemake
and only the configuration variables needed by each script
are passed as arguments to each script.

## Quarto outputs

The quarto argument `--output-dir` does not work as expected,
i.e. if it is set, quarto will not generate outputs to the specified
directory. There are dozens of discussions of this unexpected behavior
online.

It seems that the only way to redirect outputs is to specify
the output directory in a yaml file.
However, this creates a redunancy by having to specify the
`docs/` directory in more than one place.

By default, quarto generates outputs in the directory of the quarto
file.  Quarto also inexplicably loads the quarto input file
in *write* mode! Since Apptainer containers are read-only,
the quarto file and its directory must be writable. 

Here we solve both problems by mounting the current external
working directory (which contains the `scripts` directory)
as the working directory in the container.
After the quarto is finished, the snakemake rule simply
moves the files from the scripts folder to the specified
`docs` directory.

## Container image from apptainer definition rather than Dockerfile

Unfortunately docker is not available on Bristol HPC.
Although it is possible to work around this by creating
the docker image on another system, e.g. user laptop,
and running it with apptainer in HPC,
I encountered file permission issues due to docker images
being writable and apptainer images being read-only.
