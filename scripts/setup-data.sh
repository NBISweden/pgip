#!/bin/bash
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$(cd -- "$SCRIPT_PATH" && pwd)"
if [[ -z "$SCRIPT_PATH" ]] ; then
    exit 1
fi
ROOT_PATH=$(realpath ${SCRIPT_PATH}/..)

ROOTDATADIR=$(realpath ${ROOT_PATH}/docs/data)
echo "Setting up test data at ${ROOTDATADIR}"
echo ${QUARTO_PROJECT_DIR}
DATADIR=$(realpath --relative-to=$(pwd) "$ROOTDATADIR")
PGIPDATA=https://github.com/NBISweden/pgip-data.git

if [ ! -e $DATADIR ]; then
    echo Checking out pgip-data to $ROOTDATADIR
    git clone --depth 1 $PGIPDATA $DATADIR
else
    echo "$ROOTDATADIR exists; skipping setup"
fi


# Local requirements file
REQUIREMENTS=$(realpath ${ROOT_PATH}/docs/_environment.local)
REQUIREMENTS=$(realpath --relative-to=$(pwd) "$REQUIREMENTS")
if [ ! -e $REQUIREMENTS ]; then
    echo Setting up $REQUIREMENTS
    cat << EOF > $REQUIREMENTS
# NB: this should not be checked in!
# Point to google url with participant data to render in document
PARTICIPANT_DATA=foo.csv
EOF
else
    echo "$REQUIREMENTS exists; skipping setup"
fi