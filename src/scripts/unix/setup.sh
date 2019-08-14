#!/bin/bash

echo '=== Installing ==='

echo ' * Reading bundle info file'
node src/bundle/read.js

echo ' * Installing pm2'
if [ -d ".npm_cache" ]; then
  echo '    npm cache detected, installing offline..'
  npm --offline --cache ./.npm_cache --optional --cache-min 99999999999 cache verify
  npm install --global --offline --cache ./.npm_cache --optional --cache-min 99999999999 --shrinkwrap false pm2@3.5.1

else
  echo '    npm cache not detected, attempting online install..'
  npm install --global pm2@3.5.1
fi

echo ' * Configuring pm2..'
pm2 startup

echo '=== Done! ==='
