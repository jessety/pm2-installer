#!/bin/bash

echo "=== Remove ==="

echo "Removing pm2-logrotate"
pm2 delete @jessety/pm2-logrotate --silent
pm2 uninstall @jessety/pm2-logrotate --silent

echo "Removing pm2 service"
pm2 unstartup

echo "Killing pm2 process"
pm2 kill

echo "Uninstalling pm2"
npm uninstall pm2 -g --loglevel=error
npm uninstall @jessety/pm2-logrotate -g --loglevel=error

echo "=== Remove Complete ==="
