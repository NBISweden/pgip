# Population Genomics in Practice exercises

Collection of exercises for course [Population Genomics in
Practice](https://uppsala.instructure.com/courses/52168)

Under construction

## Requirements

Create a conda environment called `pgip` using the environment file

    conda env create --file environment.yaml

and install additional Python requirements with pip

    python -m pip install -r requirements.txt

Install [Quarto](https://quarto.org/), edit Quarto documents (file
extension `.qmd`) and build project with

    make

in the root directory.

## Development

### Test / development data

NB: once acceptable test data has been generated, relevant output is
added to the git repo and there is no need to regenerate it.

Install additional data development requirements

    pip install -r requirements-dev.txt

Test data can be generated in data directory as follows

    cd data
    ./make_test_data.py
