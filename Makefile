# Simple makefile for dev.

QMDFILES=$(subst docs/,docs/_site/,$(subst .qmd,.html,$(wildcard docs/*/*.qmd)))

all: $(QMDFILES)

render:
	quarto render docs

production:
	quarto render docs --profile production --cache-refresh

docs/_site/%.html: docs/%.qmd
	quarto render $< --profile production --cache-refresh

clean-build:
	rm -fR _build

clean-site:
	rm -fR docs/_site

clean-files:
	@find . -name ".pytest_cache" -exec rm -rf {} \;
	@find . -name "*undo-tree*" -exec rm -f {} \;

clean: clean-build clean-files clean-site
