## ------------------------------------------------------
## Simple makefile for development and production.
##
## Remember: for automated regeneration of output files,
## use `quarto preview`.
## ------------------------------------------------------
TEXINPUTS:=$TEXINPUTS:src/latex


help:     ## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

.phony: help Makefile

project:  ## Make project
	quarto render docs

production: ## Render project using production profile. WARNING: this will rerun all calculations
	quarto render docs --profile production --cache-refresh --log production.log


docs/_site/slides/%.html: docs/slides/%.qmd  ## Render single slides html output
	quarto render $< --profile production --cache-refresh
	mv docs/slides/$*.html $@

docs/_site/exercises/%.html: docs/exercises/%.qmd  ## Render single exercises html output
	quarto render $< --profile production --cache-refresh


clean-site: ## Remove all files in docs_site
	rm -fR docs/_site


clean: ## Remove garbage files
	find . -name tikz*.log -delete
	find . -name '.*.~undo-tree~' -delete
	find . -name *.egg-info -delete
	find . -name __pycache__ -delete


install: ## Create pgip environment and install packages to render site
	mamba env create -n pgip --file environment.yml

install-dev: ## Install additional development tools
	mamba env update -n pgip --file environment-dev.yml

install-R: ## Install additional R packages that require manual installation
	R -e "install.packages('dotenv', repos=c(CRAN = 'https://cran.rstudio.com/'))"
	R -e "tinytex::tlmgr_update()"
	R -e "tinytex::reinstall_tinytex(force=TRUE)"
	R -e "library(devtools); devtools::install_local('src/R/pgip')"
