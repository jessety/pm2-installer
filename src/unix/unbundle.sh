#!/bin/bash

echo "=== Unbundle ==="

cache_folder="./.npm_cache";
cache_archive="./bundle.tar.gz"
bundle_file="./bundle.json";

if [ -f $cache_archive ]; then
  echo "Cache archive detected, removing.."
  rm $cache_archive
else
  echo "Cache archive not detected."
fi

if [ -d $cache_folder ]; then
  echo "Cache folder detected, removing.."
  rm -rf $cache_folder
else
  echo "Cache folder not detected."
fi

if [ -f $bundle_file ]; then
  echo "Bundle info file detected, removing.."
  rm $bundle_file
else
  echo "Bundle info file not detected."
fi

echo "=== Unbundle Complete ==="
