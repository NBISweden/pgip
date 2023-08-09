# Population Genomics in Practice • Course materials

## **PGIP • Population genomics in practice**

Course materials for course [Population Genomics in
Practice](https://uppsala.instructure.com/courses/52168). Please make
sure to read the entire README before adding material.

## Installation

Clone the repo

    git clone https://github.com/NBISweden/pgip.git

and follow the instructions below.

### TL;DR

You can change the environment name by modifying the `PGIP`
environment variable:

    export PGIP=pgip
    make install-pgip
    conda activate pgip
    make install-R
    make install-kernels
    make install-bcftools
    make install-dev

If the above commands have worked without issues you are done and you
can head over to the section on [rendering
documents](#local-preview/render). If not, start by reading the
following sections that describe each installation step in more
detail. There is also a section on [known installation
issues](#installation-issues).

### Create pgip conda environment

Create a conda environment called `pgip` using the environment file

    mamba env create --file environment.yml

and activate the environment

    conda activate pgip

The environment can also be installed with the make command `make
install-pgip`.

### Install R packages

**UPDATE**: the tinytex distribution causes all kinds of trouble. See
section Installation issues below.

A number of `R` packages need to be installed manually, notably
[dotenv](https://www.rdocumentation.org/packages/dotenv/versions/1.0.3),
[tinytex](https://github.com/rstudio/tinytex-releases),
[devtools](https://devtools.r-lib.org/), and the local package `pgip`
which resides in `src/latex`. The easiest way to do so is to issue

    make install-R

in the root directory.

### Install kernels and python package

There is a helper package
[pgip-tools](https://github.com/NBISweden/pgip-tools) with code to run
simulations and more. To make use of it install with

    python -m pip install git+https://github.com/NBISweden/pgip-tools

or

    make install-kernels

The make command will also install a python kernel that can be used as
the main engine to render documents. The kernel is named `pgip` and is
detailed as a [jupyter
kernelspec](https://quarto.org/docs/computations/python.html#kernel-selection)
in the project configuration file. See [Using
Python](https://quarto.org/docs/computations/python.html) for more
information.

### Install quarto

[Install Quarto](https://quarto.org/docs/get-started) version [Quarto\>=1.2.475](https://quarto.org/docs/download/).

### bcftools manual install

Due to dependency issues, bcftools has to be manually installed:

    make install-bcftools

or

    ./scripts/install-bcftools.sh

in the root directory.

### Development tools

There are a number of development tools in `environments-dev.yaml`
that help maintain consistent coding styles and perform code quality
checks prior to committing. They can be installed either with

    mamba env update -n pgip --file environment-dev.yml

or

    make install-dev

To activate [pre-commit](https://pre-commit.com/) (recommended but not
enforced), run

    pre-commit install

From here, pre-commit will be run whenever you attempt to commit code.

### Setup environment variables

Finally, you need to set some environment variables to enable correct
rendering. For reproducibility, set these in a file `.envrc` in the
pgip root directory and source it with `source .envrc`.

On a first run you will likely encounter an `MissingEnvVarsError` for
the `PARTICIPANT_DATA` variable, which has to be set. The first run
should trigger a setup script that generates the file
`docs/_environment.local` where `PARTICIPANT_DATA` is initialized.
Rerunning `quarto preview` in the `docs` folder should suffice. Should
this for some reason fail, you can always set the variable manually:

    export PARTICIPANT_DATA="foo.csv"

The repo contains custom LaTeX code and the path `src/latex` needs to
be set via the `TEXINPUTS` variable:

    export TEXINPUTS=${TEXINPUTS}:/path/to/pgip/src/latex

### Installation issues

#### tinytex

The current TinyTeX installation setup causes errors from the TeXLive
manager `tlmgr` that are difficult to fix. As a workaround, install
`texlive` and `texlive-latex-extra`. This is the working solution in
the github CI actions. See .github/workflow/build.yml for details.

#### Missing libz2 and lzma library headers

In case you get errors related to libz2 and lzma it is likely due to
missing header files. On Ubuntu, run

    sudo apt install libz2-dev
    sudo apt install liblzma-dev

## Local preview/render

For local preview (edits to files immediately triggers regeneration of
output), cd to `docs` directory and run `quarto preview`. You can
specify a port to consistently reenter the same local web page:

    quarto preview --port 8888

There are also make rules to render single files or the entire project
('production') as they would appear online:

    make docs/_site/slides/demo/index.html
    make production

## Adding/Modifying topics

Add subdirectories to `docs/exercises` and `docs/slides` that describe
the topic in one or a few words. Shorter is better. Add an `index.qmd`
file to each directory and edit away. Look at the demo files
(`docs/slides/demo/index.qmd`,
`docs/exercises/demo/index.qmd` and `docs/exercises/demopy/index.qmd`)
for examples.

For some directories, figures and commands are run on a small data set
that is installed in `docs/data` on the first rendering. The data is
setup with the script `scripts/setup-exercise-data.sh`. To "register"
a directory for data setup, edit the script environment variable
`OOA_OUTGROUPS`, add custom setup as appropriate or create a custom
pre-render script (remember to list it in `_quarto.yml`).

### Some resources on developing content

- Rubenson (2023) How Not to Chatter like a Toddler When Giving a
  Scientific Presentation, Nature.
  [10.1038/d41586-023-00832-5](10.1038/d41586-023-00832-5)
- Crameri, Shephard & Heron (2020) The Misuse of Colour in Science
  Communication, Nature Communications.
  [10.1038/s41467-020-19160-7](10.1038/s41467-020-19160-7)

### Style guide

It is recommended you follow pre-defined style guides. To help enforce
styles and catch formatting errors early, use the linters listed
below. To this end, it is also recommended to setup pre-commit hooks.
The linters are listed as dependencies in the development requirements
file `environment-dev.yml`.

- R documents should follow the [tidyverse style
  guide](https://style.tidyverse.org/)
- python code should follow [the Black code style](https://black.readthedocs.io/en/stable/the_black_code_style/current_style.html)

### Bibliographic entries

Bibliographic entries are stored in
[BibTeX](https://en.wikipedia.org/wiki/BibTeX) format in
`docs/assets/bibliography.bib`. Add entries when necessary and cite
using quarto's [citation
syntax](https://quarto.org/docs/authoring/footnotes-and-citations.html#sec-citations)
(e.g., [@citation]).

## Development

Pushing to the `main` branch is prohibited so any updates to the
online material must be added via pull requests. Create a branch from
`main` prefixed with `dev-` (e.g., `dev-yourgithubusername`) to use as
your main development branch.

### Common linting errors

[markdownlint](https://github.com/DavidAnson/markdownlint) is run on
quarto and regular markdown files. It is possible to [disable a
linting error by adding a
comment](https://github.com/DavidAnson/markdownlint#configuration).
For instance,

    <!-- markdownlint-disable MD013 -->

    Some code here

    <!-- markdownlint-enable MD013 -->

will disable error MD013/line-length between the two comment
statements above. This is particularly useful for code blocks that are
difficult to wrap. It can also be convenient to disable error
MD041/first-line-heading/first-line-h1 when including external files
before the first heading.

### Test / development data

Test data is managed with the
[pgip-data](https://github.com/NBISweden/pgip-data) repository. The
data is setup on the first rendering with the script
`scripts/setup-data.sh`, as defined in the project definition file
`_quarto.yml` (section `project:pre-render`).

## Conda lock environment file

The conda environment file `environment.yml` lists required binaries
needed to generate the pages. Whenever a dependency is added, the
script `scripts/condalock.sh` should be run to generate a new
`conda-linux-64.lock` file that is used to install packages in the CI
environment.
