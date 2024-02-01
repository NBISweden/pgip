#!/bin/bash
#
# Setup files outside git that are required to generate site
#

SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$(cd -- "$SCRIPT_PATH" && pwd)"
if [[ -z "$SCRIPT_PATH" ]] ; then
    exit 1
fi
ROOT_PATH=$(realpath ${SCRIPT_PATH}/..)

##############################
# Local requirements file
##############################
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
