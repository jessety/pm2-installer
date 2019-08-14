@echo off

echo === Creating install bundle ===

echo * Creating .npm_cache folder..
call rmdir /s /q .npm_cache
call mkdir .npm_cache

echo * Populating .npm_cache with all global dependencies..
call npm install --global --force --cache .npm_cache --shrinkwrap false --loglevel=error pm2@3.2.4
call npm install --global --force --cache .npm_cache --shrinkwrap false --loglevel=error pm2-windows-startup@1.0.3

echo * Creating bundle info file..
call node src\bundle\write.js

echo === Done! ===
