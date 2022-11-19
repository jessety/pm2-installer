#!/usr/bin/env node

'use strict';

const { spawn } = require('child_process');
const os = require('os');
const path = require('path');

const { scripts } = require(path.join(process.cwd(), 'package.json'));
const platform = os.platform();

if (
  process.env['npm_config_argv'] === undefined &&
  process.env['npm_lifecycle_script'] === undefined
) {
  console.error('script-for-os is intended for use from an npm script only.');
  process.exit(1);
}

let targetScriptName;
let scriptParameters;

if (process.env['npm_config_argv'] !== undefined) {
  // npm < 7

  const { original: parameters } = JSON.parse(process.env['npm_config_argv']);

  [, targetScriptName, ...scriptParameters] = parameters;
} else if (
  process.env['npm_lifecycle_script'] !== undefined &&
  process.env['npm_lifecycle_event'] !== undefined
) {
  // npm >= 7

  const lifecycle = process.env['npm_lifecycle_script'];

  scriptParameters = lifecycle
    .slice(lifecycle.indexOf('.js') + 4)
    .split(' ')
    .map((parameter) => {
      if (parameter.length > 2) {
        return parameter.slice(1, -1);
      }

      return parameter;
    });

  targetScriptName = process.env['npm_lifecycle_event'];
}

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
  console.error(
    `script-for-os: Could not find script for "${targetScriptName}" to execute for this platform. Expected to find one of these in package.json/scripts:\n`,
    platformKeys.map((key) => `${targetScriptName}:${key}`),
  );
  process.exit(1);
}

let child;
const childArgs = ['run', scriptName, ...scriptParameters];

if (platform === 'win32') {
  child = spawn('npm.cmd', childArgs, { shell: true, stdio: 'inherit' });
} else {
  child = spawn('npm', childArgs, { shell: true, stdio: 'inherit' });
}

child.on('exit', (code) => {
  process.exit(code);
});
