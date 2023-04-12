#!/bin/bash
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$(cd -- "$SCRIPT_PATH" && pwd)"
if [[ -z "$SCRIPT_PATH" ]] ; then
    exit 1
fi
ROOT_PATH=$(realpath ${SCRIPT_PATH}/..)
EXERCISE_PATH=${ROOT_PATH}/docs/exercises
echo Exercise path $EXERCISE_PATH


# Link ooa-outgroups
OOA_OUTGROUPS="data_filtering genetic_diversity ld_pruning variant_calling"
for d in $OOA_OUTGROUPS; do
    ROOTDATADIR=$(realpath ${EXERCISE_PATH}/${d})
    echo "Setting up exercise data at ${ROOTDATADIR}"
    if [ ! -e ${ROOTDATADIR} ]; then
        mkdir -p ${ROOTDATADIR}
    fi
    DATADIR=$(realpath --relative-to=$(pwd) "$ROOTDATADIR")

    INDATADIR=${QUARTO_PROJECT_DIR}/data/data/ooa-outgroups
    INFILES=$(ls ${INDATADIR})
    for f in ${INFILES}; do
        source=$INDATADIR/$f
        target=${DATADIR}/$(basename $source)
        if [ ! -e ${target} ]; then
            ln -s $source ${target}
        fi
    done
done
