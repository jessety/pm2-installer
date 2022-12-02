'use strict';

console.log(`service-management\\uninstall Uninstalling`);

try {
  require('node-windows');
} catch (error) {
  console.error(
    'Could not load "node-windows", likely because it has already been uninstalled.',
  );
  process.exit(0);
}

const { Service } = require('node-windows');
const path = require('path');

// Create a "Service" object

let [directory, user, name, description] = process.argv.slice(2);

// Pull the process directory, service name, and service description from the script parameters or process env, or use a default
directory =
  directory ||
  process.env.PM2_SERVICE_DIRECTORY ||
  'c:\\ProgramData\\pm2\\service\\';
name = name || process.env.PM2_SERVICE_NAME || 'PM2';
description =
  description || process.env.PM2_SERVICE_DESCRIPTION || 'Node process manager';

const service = new Service({
  name,
  description,
  workingDirectory: directory,
  script: path.join(directory, 'index.js'),
  nodeOptions: ['--harmony'],
  stopparentfirst: true,
});

console.log(`Uninstalling service "${name}" at "${directory}"`);

if (typeof user === 'string' && user !== '') {
  service.logOnAs.account = user;
  service.logOnAs.password = ''; // This is left intentionally blank

  console.log(`Running as "${user}"`);
}

// Remove the service

// If an error occurs, print it and exit 1
service.on('error', (error) => {
  console.error(error);
  process.exit(1);
});

// If the service is already uninstalled, exit 0
service.on('alreadyuninstalled', () => {
  console.log('Service already uninstalled.');
  console.log(`service-management\\uninstall Complete`);
  process.exit(0);
});

// Once the service is uninstalled, exit 0
service.on('uninstall', () => {
  console.log('Service uninstalled.');
  console.log(`service-management\\uninstall Complete`);
  process.exit(0);
});

console.log('Uninstalling service..');

service.uninstall();
