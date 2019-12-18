#!/bin/bash

echo '=== Unbundle ==='

cache_folder="./.npm_cache";
bundle_file="./bundle.json";

if [ -d $cache_folder ]; then 
  echo 'Cache detected, removing..'
  rm -rf $cache_folder
else
  echo 'Cache not detected.'
fi

if [ -f $bundle_file ]; then 
  echo 'Bundle file detected, removing..'
  rm $bundle_file
else
  echo 'Bundle file not detected.'
fi

echo '=== Unbundle Complete ==='
