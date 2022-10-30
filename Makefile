
# Simple makefile for dev.

all:
	# Use the local build wrapper to automate writing the report log to stdout.
	#./build.sh
	quarto render docs --execute-dir docs

clean-build:
	rm -fR _build

clean-site:
	rm -fR docs/_site


clean-files:
	@find . -name ".pytest_cache" -exec rm -rf {} \;
	@find . -name "*undo-tree*" -exec rm -f {} \;


clean: clean-build clean-files clean-site
