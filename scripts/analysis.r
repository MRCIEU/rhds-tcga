## ----globals -------------------------------------------------------------
library(ggplot2)
library(ggrepel)

## ----load.data -------------------------------------------------------------
combined.filename <- file.path(paths$output.dir, "combined-clin-pred-proteins.txt")
data <- read.table(combined.filename,
                        header=T,sep="\t",stringsAsFactors=F)

## ----names -------------------------------------------------------------
## get predicted protein names
protein.names <- 
	subset(meffonym::meffonym.models(full=T), 
		grepl("^episcores", filename))$name
protein.names <- make.names(protein.names)

table(protein.names %in% colnames(data))
##TRUE 
## 109 

## ----tissue -------------------------------------------------------------

## define glm formulae with pred.proteins as predictors of 'tumor.or.normal'
## tissue i.e. tumor.or.normal ~ pred.protein
formulae <- sapply(protein.names, function(i){
		reformulate(i, response = "tumor")
		}, simplify = F)

# run glms 
fit <- sapply(formulae, function(i){
	glm(i, data = data, family = binomial())
	}, simplify = F)

fit.summary <- sapply(fit ,function(i){
	out <- summary(i)$coefficients
	out[,"Estimate"] <- out[,"Estimate"]
	out
	}, simplify = F)

fit.coefs <- sapply(fit.summary, function(i){
	i[2, c("Estimate", "Pr(>|z|)")]
	}, simplify = F) 
fit.coefs <- {
	x <- do.call(rbind, fit.coefs)
	data.frame(
		pred.protein = rownames(x),
		coef = x[, "Estimate"],
		p.value = x[, "Pr(>|z|)"]
	)
}

bonferroni <- -log10(0.05/length(fit))

## ----tissue.figs -------------------------------------------------------------
fit.coefs |>
	ggplot(aes(x = pred.protein, y = -log10(p.value))) +
		geom_point()+ 
		theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
		geom_text_repel(
			data = fit.coefs[which((-log10(fit.coefs$p.value) > bonferroni)), ], 
		    	aes(x=pred.protein,y=-log10(p.value),label=pred.protein))+ 
		geom_hline(yintercept = bonferroni, 
			linetype='dashed')

fit.coefs |>
		ggplot(aes(x = coef, y = -log10(p.value))) +
		geom_point()+
		geom_text_repel(
			data = fit.coefs[which((-log10(fit.coefs$p.value) > bonferroni)), ], 
		    	aes(x=coef,y=-log10(p.value),label=pred.protein))+ 
		geom_hline(yintercept = bonferroni, 
			linetype='dashed')


## ----pfi -------------------------------------------------------------
tumor.data <- subset(data, tumor ==1)

## define glm formulae with pred.proteins as predictors of pfi
## tissue i.e. pfi ~ pred.protein
formulae <- sapply(protein.names, function(i){
		reformulate(i, response = "pfi")
		}, simplify = F)

# run glms 
fit <- sapply(formulae, function(i){
	glm(i, data = tumor.data, family = binomial())
	}, simplify = F)

fit.summary <- sapply(fit ,function(i){
	out <- summary(i)$coefficients
	out[,"Estimate"] <- out[,"Estimate"]
	out
	}, simplify = F)

fit.coefs <- sapply(fit.summary, function(i){
	i[2, c("Estimate", "Pr(>|z|)")]
	}, simplify = F) 
fit.coefs <- {
	x <- do.call(rbind, fit.coefs)
	data.frame(
		pred.protein = rownames(x),
		coef = x[, "Estimate"],
		p.value = x[, "Pr(>|z|)"]
	)
}

## ----pfi.figs -------------------------------------------------------------
fit.coefs |>
	ggplot(aes(x = pred.protein, y = -log10(p.value))) +
		geom_point()+ 
		theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
		geom_text_repel(
			data = fit.coefs[which((-log10(fit.coefs$p.value) > bonferroni)), ], 
		    	aes(x=pred.protein,y=-log10(p.value),label=pred.protein))+ 
		geom_hline(yintercept = bonferroni, 
			linetype='dashed')

fit.coefs |>
		ggplot(aes(x = coef, y = -log10(p.value))) +
		geom_point()+
		geom_text_repel(
			data = fit.coefs[which((-log10(fit.coefs$p.value) > bonferroni)), ], 
		    	aes(x=coef,y=-log10(p.value),label=pred.protein))+ 
		geom_hline(yintercept = bonferroni, 
			linetype='dashed')
