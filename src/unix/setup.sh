#!/bin/bash

echo '=== Setup ==='

# Load the correct versions
pm2_package=$(node src/echo-dependency.js pm2)
pm2_logrotate_package=$(node src/echo-dependency.js pm2-logrotate)
cache_folder="./.npm_cache";

# Print out the versions of this package, node, and npm for this host
node src/bundle/current.js

echo ' * Installing pm2'
if [ -d $cache_folder ]; then

  # Read the bundle information file and compare it to the current host
  node src/bundle/compare.js

  echo 'Cache detected, installing offline..'
  npm --offline --cache ./.npm_cache --optional --cache-min 99999999999 cache verify

  npm install --global --offline --cache $cache_folder --cache-min 99999999999 --shrinkwrap false --loglevel=error $pm2_package
  npm install --global --offline --cache $cache_folder --cache-min 99999999999 --shrinkwrap false --loglevel=error $pm2_logrotate_package

else
  echo 'Cache not detected, installing online..'
  npm install --global --loglevel=error $pm2_package
  npm install --global --loglevel=error $pm2_logrotate_package
fi

# Run pm2 on startup
pm2 startup

# Add the logrotate module
cd "$(npm config get prefix)/lib/node_modules/pm2-logrotate/"
pm2 install . --silent
pm2 save --force

echo '=== Setup Complete ==='
