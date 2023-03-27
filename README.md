# Population Genomics in Practice • Course materials

## **PGIP • Population genomics in practice**

Course materials for course [Population Genomics in
Practice](https://uppsala.instructure.com/courses/52168)

## Setup

Clone the repo

    git clone https://github.com/NBISweden/pgip.git

and follow the instructions below.

## Requirements

- To preview/render, you must use
  [Quarto\>=1.2.269](https://quarto.org/docs/download/)

Create a conda environment called `pgip` using the environment file

    mamba env create --file environment.yml

and activate the environment

    conda activate pgip

Install additional Python requirements with pip

    python -m pip install -r requirements.txt

Install test data and local quarto environment files as

    ./scripts/setup-data.sh

Install [Quarto](https://quarto.org/), edit Quarto documents (file
extension `.qmd` in `docs` directory and subdirectories) and build
project with `make` in the root directory.

## Local preview/render

### Organization

The root directory contains

### Single documents

To render a single document (e.g.,
`docs/_site/slides/datageneration.html`), you can use the file name as
a make target:

    make docs/_site/slides/datageneration.html

The quarto source to this file is `docs/slides/datageneration.qmd`.

### The all target

The generic `make` target `all`, which is run without any arguments
being passed to `make`, is a list of all output html files that will
be rendered in `docs/_site`. This avoids rerunning compilation of all
files which is the case when rendering an entire project (e.g.,
`quarto render docs`). In addition, this allows for rendering
documents in parallel:

    make -j 4

Run with `-n -B` options to compile a list of all targets and commands:

    make -n -B

### Production target

Finally, the production target, which is what is run on GitHub and
will build the entire project, can be invoked as

    make production

## Development

### Test / development data

Install additional data development requirements and helper
applications with

    pip install -r requirements-dev.txt

Test data is managed with the
[pgip-data](https://github.com/NBISweden/pgip-data) repository. The
data will be downloaded on the first invocation of `make`.

## Conda environment file

The conda environment file `environment.yml` lists required binaries
needed to generate the pages. Whenever a dependency is added, the
script `scripts/condalock.sh` should be run to generate a new
`conda-linux-64.lock` file that is used to install packages in the CI
environment.
