#!/bin/bash

echo '=== Bundle ==='

pm2_package=$(node src/echo-dependency.js pm2)
pm2_logrotate_package=$(node src/echo-dependency.js pm2-logrotate)
cache_folder="./.npm_cache";

# Create a new npm cache folder
rm -rf $cache_folder
mkdir -p $cache_folder

echo 'Populating cache with all global dependencies..'
npm install --global --force --cache $cache_folder --shrinkwrap false --loglevel=error $pm2_package
npm install --global --force --cache $cache_folder --shrinkwrap false --loglevel=error $pm2_logrotate_package

# Write system information to bundle file
node src/bundle/write.js

echo '=== Bundle Complete ==='
