#!/bin/bash

echo ' * Killing pm2..'
pm2 kill

echo ' * Removing pm2 startup..'
pm2 unstartup

echo ' * Uninstalling pm2..'
npm uninstall pm2 -g

echo 'Done!'
