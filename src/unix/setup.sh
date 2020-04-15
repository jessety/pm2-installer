#!/bin/bash

echo '=== Setup ==='

# Load the correct versions
pm2_package=$(node src/echo-dependency.js pm2)
pm2_logrotate_package=$(node src/echo-dependency.js pm2-logrotate)
cache_folder="./.npm_cache";
cache_archive="./bundle.tar.gz"

# Print out the versions of this package, node, and npm for this host
node src/bundle/current.js

if [ -f $cache_archive ]; then

  echo 'Cache detected, installing offline..'

  # Remove existing cache directory
  rm -rf $cache_folder

  # Extract the archive to create a new cache directory
  tar -xf $cache_archive

  # Read the bundle information file and compare it to the current host
  node src/bundle/compare.js

  npm --offline --cache $cache_folder --optional cache verify

  npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error --audit=false --no-fund $pm2_package
  npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error --audit=false --no-fund $pm2_logrotate_package

else
  echo 'Cache not detected, installing online..'
  npm install --global --loglevel=error --audit=false --no-fund $pm2_package
  npm install --global --loglevel=error --audit=false --no-fund $pm2_logrotate_package
fi

# Run pm2 on startup
pm2 startup

# Add the logrotate module
cd "$(npm config get prefix)/lib/node_modules/pm2-logrotate/"
pm2 install . --silent
pm2 save --force

echo '=== Setup Complete ==='
