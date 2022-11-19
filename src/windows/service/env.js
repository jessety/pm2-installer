'use strict';

const { execSync } = require('child_process');
const path = require('path');
const process = require('process');

// Load all the ENV values we need

function installDirectory() {
  const key = 'PM2_INSTALL_DIRECTORY';

  let value = process.env[key];

  if (value !== undefined && value !== '') {
    return value;
  }

  // Attempt to determine where pm2 is likely installed

  const { stdout, stderr } = execSync('npm config get prefix --global');

  if (stderr.trim() !== '') {
    console.log(
      `$env:${key} is blank, and we can't estimate the location manually.`,
    );
    throw new Error(stderr.trim());
  }

  value = path.join(stdout.trim(), 'node_modules', 'pm2');

  console.warn(`$env:${key} is blank, assuming "${value}"`);

  process.env[key] = value;

  return value;
}

function homeDirectory() {
  const key = 'PM2_HOME';

  let value = process.env[key];

  if (value !== undefined && value !== '') {
    return value;
  }

  value = `C:\\ProgramData\\pm2\\home\\`;

  console.warn(`$env:${key} is blank, assuming "${value}"`);

  process.env[key] = value;

  return value;
}

function serviceDirectory() {
  const key = 'PM2_SERVICE_DIRECTORY';

  let value = process.env[key];

  if (value !== undefined && value !== '') {
    // console.log(`$env:${key} is: ${value}`);
    return value;
  }

  value = `C:\\ProgramData\\pm2\\service\\`;

  console.warn(`$env:${key} is blank, assuming "${value}"`);

  process.env[key] = value;

  return value;
}

// Figure out where this service is installed

const PM2_SERVICE_DIRECTORY = serviceDirectory();

// Discern the location of the PM2_HOME directory

const PM2_HOME = homeDirectory();

// Acquire a reference to the global pm2 installation

const PM2_INSTALL_DIRECTORY = installDirectory();

module.exports = { PM2_HOME, PM2_INSTALL_DIRECTORY, PM2_SERVICE_DIRECTORY };
