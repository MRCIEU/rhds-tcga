
# Set CRAN repository to Posit Package Manager with pre-built binaries from a specific date
options(repos = c(CRAN = sprintf("https://packagemanager.posit.co/cran/2025-12-07/bin/linux/noble-%s/%s", R.version["arch"], substr(getRversion(), 1, 3))))

# Install required packages from CRAN to user directory
install.packages(c(
    "remotes",
    "data.table",
    "R.utils",
    "ggplot2",
    "ggrepel",
    "readxl",
    "here",
    "rmarkdown"
))

# Install specific version of meffonym package from GitHub
remotes::install_github("perishky/meffonym@9faface")
