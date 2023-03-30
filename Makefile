# Simple makefile for dev.
QMDFILES=$(subst docs/,docs/_site/,$(subst .qmd,.html,$(wildcard docs/*/*/*.qmd)))

all: $(QMDFILES)

render:
	quarto render docs

production:
	quarto render docs --profile production --cache-refresh --log production.log

docs/_site/slides/%.html: docs/slides/%.qmd
	quarto render $< --profile production --cache-refresh
	mv docs/slides/$*.html $@

docs/_site/%.html: docs/%.qmd
	quarto render $< --profile production --cache-refresh

clean-site:
	rm -fR docs/_site

# Exclude directory from find . command
# https://stackoverflow.com/questions/4210042/exclude-directory-from-find-command
GARBAGE_TYPES         := __pycache__ .*.~undo-tree~ *.egg-info tikz*.log
DIRECTORIES_TO_CLEAN  := $(shell find -not -path "./.git**" -type d)
GARBAGE := $(foreach DIR, $(DIRECTORIES_TO_CLEAN), $(addprefix $(DIR)/,$(GARBAGE_TYPES)))

clean:
	@$(RM) -rf $(GARBAGE)
