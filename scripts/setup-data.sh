#!/bin/bash

echo "Setting up test data"

DATADIR=data
PGIPDATA=git@github.com:NBISweden/pgip-data.git

if [ ! -e $DATADIR ]; then
    echo Checking out pgip-data to $DATADIR
    git clone --depth 1 $PGIPDATA $DATADIR
else
    echo "$DATADIR exists; skipping setup"
fi
