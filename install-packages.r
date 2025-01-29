## package names
cran <- c("data.table", "readxl", "knitr", "RPMM", "remotes", "tidyverse")
bioc <- c("IlluminaHumanMethylation450kanno.ilmn12.hg19", "impute")
github <- c("perishky/meffonym")

packages <- c(cran,bioc, github)
installed <- sapply(basename(packages), require, character.only=T)
installed

if (sum(installed) < length(installed)){

    index <- intersect(
                which(names(installed) %in% cran), 
                which(installed == FALSE))

        if(length(index) > 0){
            cat("Installing", names(installed[index]), "from CRAN", "\n")
            options(repos = "https://cloud.r-project.org")            
            install.packages(names(installed[index]))
        }

    index <- intersect(
                which(names(installed) %in% bioc), 
                which(installed == FALSE))

        if(length(index) > 0){
            if (!require("BiocManager", quietly = TRUE))
                install.packages("BiocManager")
            cat("Installing", names(installed[index]), "from Bioconductor", "\n")            
            BiocManager::install(names(installed[index]))
        }

    index <- intersect(
                which(names(installed) %in% basename(github)), 
                which(installed == FALSE))

        if(length(index) > 0){
            cat("Installing", basename(packages[index]), "from", packages[index],
                "repo on github", "\n")            
            remotes::install_github(packages[index])
        }

}

installed <- sapply(basename(packages), require, character.only=T)
cat("Of the below packages required: \n",
    names(installed),
    "\n \n the following are available: \n", 
    names(installed[which(installed == T)]), "\n")

