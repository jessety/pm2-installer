#!/bin/bash

echo "=== Remove ==="

echo "Killing pm2 process"
pm2 kill

echo "Removing pm2 service"
pm2 unstartup

echo "Uninstalling pm2"
npm uninstall pm2 -g --loglevel=error
npm uninstall pm2-logrotate -g --loglevel=error

echo "=== Remove Complete ==="
