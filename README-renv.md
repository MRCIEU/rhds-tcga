To set up renv snapshot, start R, install renv and initialize renv.

```r
install.packages("renv")
renv::init(bioconductor="3.20")
```

Restart R, install packages and record these package versions in the lock file.

```r
renv::install()
renv::install("perishky/meffonym")
renv::snapshot()
```
