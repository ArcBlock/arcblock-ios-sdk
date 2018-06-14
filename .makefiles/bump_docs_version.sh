#!/bin/bash

cur_ver=$(cat .jazzy.yaml | grep module_version |  head -1 | awk '{print $2}')
new_ver=$(cat version)
cat .jazzy.yaml | sed "s/"${cur_ver}"/${new_ver}/g" >  .jazzy.yaml.tmp
mv .jazzy.yaml.tmp .jazzy.yaml
