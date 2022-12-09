#!/bin/bash

echo "Setting up test data"

SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$(cd -- "$SCRIPT_PATH" && pwd)"
if [[ -z "$SCRIPT_PATH" ]] ; then
  exit 1
fi
ROOT_PATH=$(realpath ${SCRIPT_PATH}/..)

DATADIR=$(realpath ${ROOT_PATH}/docs/data)
DATADIR=$(realpath --relative-to=$(pwd) "$DATADIR")
PGIPDATA=https://github.com/NBISweden/pgip-data.git

if [ ! -e $DATADIR ]; then
    echo Checking out pgip-data to $DATADIR
    git clone --depth 1 $PGIPDATA $DATADIR
else
    echo "$DATADIR exists; skipping setup"
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
