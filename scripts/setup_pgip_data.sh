#!/bin/bash
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$(cd -- "$SCRIPT_PATH" && pwd)"
if [[ -z "$SCRIPT_PATH" ]] ; then
    exit 1
fi
ROOT_PATH=$(realpath ${SCRIPT_PATH}/..)

ROOTDATADIR=$(realpath ${ROOT_PATH}/docs/pgip_data)
echo "Setting up pgip-data repository at ${ROOTDATADIR}"
echo ${QUARTO_PROJECT_DIR}
DATADIR=$(realpath --relative-to=$(pwd) "$ROOTDATADIR")
PGIPDATA=https://github.com/NBISweden/pgip-data.git

if [ ! -e $DATADIR ]; then
    echo Checking out pgip-data to $ROOTDATADIR
    git clone --depth 1 $PGIPDATA $DATADIR
else
    echo "$ROOTDATADIR exists; skipping setup"
fi
