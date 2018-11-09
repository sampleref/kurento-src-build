#!/bin/bash
echo Checking out $2 in path $1
cd $1
for d in $(find . -maxdepth 1 -mindepth 1 -type d)
do pushd $d ; git checkout "$2" ; popd ; done