#!/bin/bash

cur_ver=$(cat ArcBlockSDK.podspec | grep s.version |  head -1 | awk '{print $3}' | sed "s/'//g")
new_ver=$(cat version)
cat ArcBlockSDK.podspec | sed "s/"${cur_ver}"/${new_ver}/g" >  ArcBlockSDK.podspec.tmp
# mv ArcBlockSDK.podspec.tmp ArcBlockSDK.podspec
