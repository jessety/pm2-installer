#!/usr/bin/env node

'use strict';

const os = require('os');
const path = require('path');
const { spawn } = require('child_process');

const { scripts } = require(path.join(process.cwd(), 'package.json'));
const platform = os.platform();

if (!process.env['npm_config_argv']) {
  console.error('script-for-os is intended for use from an npm script only.');
  return;
}

const { original: parameters } = JSON.parse(process.env['npm_config_argv']);

const [, targetScriptName, ...scriptParameters] = parameters;

const platformKeys = [platform];

if (platform === 'darwin') {
  platformKeys.push('macos');
}

if (platform === 'win32') {
  platformKeys.push('windows');
}

if (['darwin', 'linux', 'freebsd', 'android'].includes(platform)) {
  platformKeys.push('unix');
}

platformKeys.push('default');

let scriptName;

for (const platform of platformKeys) {

  const key = `${targetScriptName}:${platform}`;

  if (scripts[key] === undefined) {
    continue;
  }

  scriptName = key;
  break;
}

if (scriptName === undefined) {
  console.error(`script-for-os: Could not find script for "${targetScriptName}" to execute for this platform. Expected to find one of these in package.json/scripts:\n`, platformKeys.map(key => `${targetScriptName}:${key}`));
  return;
}

let child;
const childArgs = ['run', scriptName, ...scriptParameters];

if (platform === 'win32') {
  child = spawn('npm.cmd', childArgs, { shell: true, stdio: 'inherit' });
} else {
  child = spawn('npm', childArgs, { shell: true, stdio: 'inherit' });
}

child.on('exit', code => {
  process.exit(code);
});
