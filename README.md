# Population Genomics in Practice exercises

Collection of exercises for course [Population Genomics in
Practice](https://uppsala.instructure.com/courses/52168)

Under construction

## Setup

Clone the repo

    git clone https://github.com/NBISweden/pgip.git

and follow the instructions below.

## Requirements

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
project with

    make

in the root directory.

## Development

### Test / development data

Install additional data development requirements

    pip install -r requirements-dev.txt

Test data is managed with the
[pgip-data](https://github.com/NBISweden/pgip-data) repository. The
data will be downloaded on the first invocation of `make`.
