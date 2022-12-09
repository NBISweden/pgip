#!/bin/bash
set -xeuo pipefail
echo "generating conda-linux-64.lock from environment.yml"
conda-lock --kind explicit --platform linux-64
