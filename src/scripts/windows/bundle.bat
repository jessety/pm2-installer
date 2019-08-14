@echo off

echo === Creating install bundle ===

echo * Cleaning bundle folder
call rmdir /s /q .bundle
call mkdir .bundle
call mkdir .bundle\npm
call mkdir .bundle\npm-cache

echo * Clearing global npm cache
call npm cache clean --force --loglevel=error

echo * Removing pm2 and pm2-windows-startup
call pm2 kill
call pm2-startup uninstall
call npm uninstall --global pm2
call npm uninstall --global pm2-windows-startup

echo * Removing all globally installed npm packages
call del /f /s /q %AppData%\npm\ > nul
for /d %%p in (%AppData%\npm\*) Do rd /Q /S "%%p"

echo * Installing pm2 and pm2-windows-startup
call npm install --global --force --loglevel=error pm2@3.2.4
call npm install --global --force --loglevel=error pm2-windows-startup@1.0.3

echo * Copying npm and npm-cache AppData folders into bundle

call robocopy %AppData%\npm .\.bundle\npm /s /e /nfl /ndl /njh /njs
call robocopy %AppData%\npm-cache .\.bundle\npm-cache /s /e /nfl /ndl /njh /njs

echo * Creating bundle info file..
call node src\bundle\write.js

echo === Done! ===
