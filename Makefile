## ------------------------------------------------------
## Simple makefile for development and production.
##
## Remember: for automated regeneration of output files,
## cd to docs directory and run `quarto preview`.
## ------------------------------------------------------
TEXINPUTS:=$TEXINPUTS:src/latex


help:     ## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

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


install-pgip: ## Create pgip environment and install packages to render site
	if conda env list | cut -f1 -d ' ' | grep -q "pgip$$"; then \
		echo "Environment exists; skipping install"; \
	else \
		mamba env create -n pgip --file environment.yml; \
	fi;

install-dev: install-pgip ## Install additional development tools
	mamba env update -n pgip --file environment-dev.yml

install-R: install-pgip ## Install additional R packages that require manual installation
	R -e "install.packages('dotenv', repos=c(CRAN = 'https://cran.rstudio.com/'))"
	R -e "tinytex::tlmgr_update()"
	R -e "tinytex::reinstall_tinytex(force=TRUE)"
	R -e "library(devtools); devtools::install_local('src/R/pgip')"

install-kernels: install-pgip ## Install python and bash kernel
	python -m pip install git+https://github.com/NBISweden/pgip-tools
	python -m bash_kernel.install
	python -m ipykernel install --user --name pgip --display-name "Population Genomics in Practice (Python)"

install-bcftools: ## Install bcftools manually due to issues with conda version 1.8
	scripts/install-bcftools.sh

.phony: help Makefile project production clean-site clean install-pgip install-dev install-R install-kernels bcftools
