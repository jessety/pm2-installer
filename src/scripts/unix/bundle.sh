#!/bin/bash

echo '=== Creating install bundle ==='

echo ' * Creating .npm_cache folder..';
rm -rf ./.npm_cache
mkdir -p ./.npm_cache

echo ' * Populating .npm_cache with all global dependencies..'
npm install --global --force --cache ./.npm_cache --shrinkwrap false --loglevel=error pm2@3.5.1

echo ' * Creating bundle info file..'
node src/bundle/write.js

echo '=== Done! ==='
