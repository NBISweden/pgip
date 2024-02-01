#!/bin/bash
#
# This script is used to build the docker image for the application.
#
SCRIPT_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
SCRIPT_PATH="$(cd -- "$SCRIPT_PATH" && pwd)"
if [[ -z "$SCRIPT_PATH" ]] ; then
    exit 1
fi
ROOT_PATH=$(realpath ${SCRIPT_PATH}/..)

docker build -t "workshop-pgip:latest" ${SCRIPT_PATH}
docker tag workshop-pgip ghcr.io/nbisweden/workshop-pgip:latest
docker push ghcr.io/nbisweden/workshop-pgip:latest
