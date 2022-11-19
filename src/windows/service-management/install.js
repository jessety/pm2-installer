'use strict';

console.log(`service-management\\install Installing`);

try {
  require('node-windows');
} catch (error) {
  console.error(
    'Could not load "node-windows", likely because it has already been uninstalled.',
  );
  process.exit(1);
}

const { Service } = require('node-windows');
const path = require('path');

// Ensure all the environmental variables we need are populated

for (const key of [
  'PM2_HOME',
  'PM2_INSTALL_DIRECTORY',
  'PM2_SERVICE_DIRECTORY',
]) {
  if (process.env[key] === undefined) {
    console.error(`ERROR: $env:${key} is undefined. Halting installation.`);
    console.log(`Please set $env:${key} and run this script again.`);
    process.exit(1);
  }
}

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

console.log(`Installing service "${name}" at "${directory}"`);

if (typeof user === 'string' && user !== '') {
  service.logOnAs.account = user;
  service.logOnAs.password = ''; // This is left intentionally blank

  console.log(`Running as "${user}"`);
}

// Install the service

// If an error occurs, print it and exit 1
service.on('error', (error) => {
  console.error(error);
  process.exit(1);
});

// If the service is already installed, exit 0
service.on('alreadyinstalled', () => {
  console.log('Already installed.');
  console.log(`service-management\\install Complete`);
  process.exit(0);
});

// Once the service is installed, start it
service.on('install', () => {
  // console.log(`Installed! Starting..`);
  // service.start();
  console.log(`service-management\\install Complete`);
  process.exit(0);
});

// Once the service has started, exit
// service.on('start', () => {
//   console.log(`Started!`);
//   console.log(`service-management\\install Complete`);
//   process.exit(0);
// });

// Install the script as a service.
service.install();
