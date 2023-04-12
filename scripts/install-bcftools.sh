#!/bin/bash

mkdir -p opt
cd opt || return
wget https://github.com/samtools/bcftools/releases/download/1.17/bcftools-1.17.tar.bz2
wget https://github.com/samtools/htslib/releases/download/1.17/htslib-1.17.tar.bz2
tar -jxvf htslib-1.17.tar.bz2 && rm -f htslib-1.17.tar.bz2
tar -jxvf bcftools-1.17.tar.bz2 && rm -f bcftools-1.17.tar.bz2
cd bcftools-1.17 || return
sed -i -e 's@/usr/local@'"$CONDA_PREFIX"'@' Makefile
make
make install
