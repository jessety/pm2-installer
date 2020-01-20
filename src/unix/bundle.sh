#!/bin/bash

echo '=== Bundle ==='

pm2_package=$(node src/echo-dependency.js pm2)
pm2_logrotate_package=$(node src/echo-dependency.js pm2-logrotate)
cache_folder="./.npm_cache";

# Create a new npm cache folder
rm -rf $cache_folder
mkdir -p $cache_folder

echo 'Populating cache with all dependencies..'
npm install --global-style --force --cache $cache_folder --loglevel=error $pm2_package
npm install --global-style --force --cache $cache_folder --loglevel=error $pm2_logrotate_package

echo 'Removing local npm_modules folder..'
rm -rf node_modules

# Write system information to bundle file
node src/bundle/write.js

echo '=== Bundle Complete ==='
