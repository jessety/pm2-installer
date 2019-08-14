@echo off

echo === Installing ===

echo * Reading bundle info
call node src\bundle\read.js

echo * Installing pm2
if exist .bundle (
  echo    bundle directory detected, copying npm and npm-cache AppData folders into place
  call robocopy .\.bundle\npm "%AppData%\npm" /s /e /nfl /ndl /njh /njs
  call robocopy .\.bundle\npm-cache "%AppData%\npm-cache" /s /e /nfl /ndl /njh /njs
) else (
  echo    bundle directory not detected, installing using online mode
  call npm install --global pm2@3.2.4
  call npm install --global pm2-windows-startup@1.0.3
)

echo * Updating PATH
set PATH=%PATH%;%AppData%\npm

echo * Configuring pm2
call pm2-startup install
call pm2 save

echo === Done! ===
