#!/bin/bash

echo "=== Bundle ==="

pm2_package=$(node src/tools/dependencies/echo.js pm2)
pm2_logrotate_package=$(node src/tools/dependencies/echo.js @jessety/pm2-logrotate)

cache_folder="./.npm_cache";
cache_archive="./bundle.tar.gz"

# Remove existing bundle files
rm -rf $cache_folder
mkdir -p $cache_folder
rm -rf $cache_archive
rm -rf node_modules

echo "Populating cache with all dependencies.."
npm install --no-save --global-style --force --cache $cache_folder --loglevel=error --no-audit --no-fund "$pm2_package"
npm install --no-save --global-style --force --cache $cache_folder --loglevel=error --no-audit --no-fund "$pm2_logrotate_package"

echo "Removing local npm_modules folder.."
rm -rf node_modules

echo "Compressing cache.."
tar -czf $cache_archive $cache_folder
rm -rf $cache_folder

# Write system information to bundle file
node src/bundle-info/write.js

echo "=== Bundle Complete ==="
