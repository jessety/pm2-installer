@echo off

echo * Killing pm2..
call pm2 kill

echo * Removing pm2 startup..
call pm2-startup uninstall

echo * Uninstalling pm2..
call npm uninstall pm2-windows-startup -g
call npm uninstall pm2 -g

echo Done!
