#!/bin/bash
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$(cd -- "$SCRIPT_PATH" && pwd)"
if [[ -z "$SCRIPT_PATH" ]] ; then
    exit 1
fi
ROOT_PATH=$(realpath ${SCRIPT_PATH}/..)
SLIDES_PATH=${ROOT_PATH}/docs/slides
echo Slides path $SLIDES_PATH

# Link HSAP genomes data
HSAP="foundations "
for d in ${HSAP}; do
    ROOTDATADIR=$(realpath ${SLIDES_PATH}/${d})
    echo "Setting up slides data at ${ROOTDATADIR}"
    if [ ! -e ${ROOTDATADIR} ]; then
        mkdir -p ${ROOTDATADIR}
    fi
    DATADIR=$(realpath --relative-to=$(pwd) "$ROOTDATADIR")
    INDATADIR=${QUARTO_PROJECT_DIR}/data/data/Homo_sapiens
    source=$INDATADIR
    mkdir -p ${DATADIR}/data
    target=${DATADIR}/data/$(basename $source)
    if [ ! -e ${target} ]; then
        ln -s $source ${target}
    fi
done
