@echo off

echo === Installing ===

echo * Reading bundle info file..
call node src\bundle\read.js

echo * Installing hse-api dependencies..
call npm install

echo * Installing pm2..
if exist .npm_cache (
  echo    npm cache detected, installing offline..
  call npm --offline --cache ./.npm_cache --optional --cache-min 99999999999 cache verify
  call npm install --global --offline --cache .npm_cache --optional --cache-min 99999999999 --shrinkwrap false pm2@3.2.4
  call npm install --global --offline --cache .npm_cache --optional --cache-min 99999999999 --shrinkwrap false pm2-windows-startup@1.0.3
) else (
  echo    npm cache not detected, installing online..
  call npm install --global pm2@3.2.4
  call npm install --global pm2-windows-startup@1.0.3
)

echo * Updating PATH..
set PATH=%PATH%;%AppData%\npm

echo * Configuring pm2..
call pm2-startup install
call pm2 save

echo === Done! ===
  