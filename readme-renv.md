# Creation of the renv lock file

The renv packages was installed and initialized in R.

```r
install.packages("renv")
renv::init(bioconductor="3.20")
```

After restarting R,
package dependencies were installed and
there versions saved to the lock file.

```r
renv::install()
renv::install("perishky/meffonym")
renv::snapshot()
```
