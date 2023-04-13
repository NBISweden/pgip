#!/bin/bash
set -xeuo pipefail

if [[ $# == 1 ]]; then
    if [[ "$1" == "--force" ]]; then
        echo "generating conda-linux-64.lock from environment.yml"
        conda-lock --kind explicit --platform linux-64
    else
        echo "Usage: $0 [--force]"
        exit 1
    fi
else
    SRC_PATTERN="environment*.yml"
    if git diff --cached --name-only | grep --quiet "$SRC_PATTERN"; then
        if git diff --cached --name-only | grep --quiet "conda-linux-64.lock"; then
            echo "conda-linux-64.lock staged"
        else
            echo "Detected changes in environment.yml; run condalock.sh --force and commit conda-lock file"
            exit 1
        fi
    fi
fi
