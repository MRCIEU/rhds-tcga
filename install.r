options(repos = c(CRAN = sprintf("https://packagemanager.posit.co/cran/2025-12-07/bin/linux/noble-%s/%s", R.version["arch"], substr(getRversion(), 1, 3))))
install.packages(c(
    "remotes",
    "ggplot2",
    "ggrepel",
    "readxl",
    "here"
))
remotes::install_github("perishky/meffonym@9faface")
