#!/bin/bash

echo "=== Setup ==="

pm2_package=$(node src/tools/dependencies/echo.js pm2)
pm2_logrotate_package=$(node src/tools/dependencies/echo.js @jessety/pm2-logrotate)

cache_folder="./.npm_cache";
cache_archive="./bundle.tar.gz"

# Print out the versions of this package, node, and npm for this host
node src/bundle-info/current.js

# Check connectivity to registry.npmjs.org
node src/tools/npm-online.js

if [ $? -eq 0 ]; then

  echo "Installing pm2.."

  npm install --global --loglevel=error --no-audit --no-fund "$pm2_package"

  echo "Installing pm2-logrotate.."

  pm2 install "$pm2_logrotate_package"

else

  echo "Cannot connect to the npm registry. Checking for offline bundle.."

  if [ -f $cache_archive ]; then

    echo "Cache bundle detected. Decompressing.."

    # Remove existing cache directory
    rm -rf $cache_folder

    # Extract the archive to create a new cache directory
    tar -xf $cache_archive

    # Read the bundle information file and compare it to the current host
    node src/bundle-info/compare.js

    npm --offline --cache $cache_folder --optional cache verify

    echo "Installing packages offline.."
    npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error --no-audit --no-fund "$pm2_package"
    npm install --global --offline --cache $cache_folder --shrinkwrap false --loglevel=error --no-audit --no-fund "$pm2_logrotate_package"

    echo "Installing pm2-logrotate.."
    cd "$(npm config get prefix)/lib/node_modules/@jessety/pm2-logrotate/" || exit
    pm2 install . --silent
    pm2 save --force

  else

    echo "Offline bundle not detected. Attempting to install dependencies anyway.."

    echo "Installing pm2.."

    npm install --global --loglevel=error --no-audit --no-fund "$pm2_package"

    echo "Installing pm2-logrotate.."

    pm2 install "$pm2_logrotate_package"

  fi
fi

# Run pm2 on startup
pm2 startup

echo "=== Setup Complete ==="
