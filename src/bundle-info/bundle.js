'use strict';

const { name, version } = require('../../package.json');
// Normally it'd make sense to just require 'simple-log-colors'
// --but we want to be sure this will function without any dependencies
// (for pretty obvious reasons)
// const colors = require('simple-log-colors');
const colors = require('./colors');
const fs = require('fs');
const os = require('os');
const { promisify } = require('util');

const writeFile = promisify(fs.writeFile);
const readFile = promisify(fs.readFile);
const exec = promisify(require('child_process').exec);

const path = 'bundle.json';

async function info() {
  const { stdout, stderr } = await exec('npm --version');

  let npm;

  if (stderr) {
    console.error(`Error checking npm version: ${stderr}`);
  } else {
    npm = stdout.trim();
  }

  const node = process.version;

  const time = new Date().getTime() / 1000;
  const date = new Date().toLocaleDateString();

  const platform = os.platform();
  const release = os.release();

  return {
    time,
    date,

    node,
    npm,

    package: {
      name,
      version,
    },

    os: {
      platform,
      release,
    },
  };
}

function describe(bundle) {
  if (bundle === undefined) {
    return;
  }

  const { cyan } = colors;

  const { time, node, npm } = bundle;
  const { name, version } = bundle.package;
  const { platform, release } = bundle.os;

  const date = new Date(time * 1000);

  return `${date.toLocaleDateString()}, ${name} ${cyan(
    version,
  )} with node ${cyan(node)} and npm ${cyan(npm)} on ${cyan(platform)}-${cyan(
    release,
  )}.`;
}

async function compare(bundle, current) {
  if (bundle === undefined) {
    console.error(`${colors.red('×')} Offline install bundle appears invalid.`);
    return;
  }

  if (current === undefined) {
    current = await info();
  }

  const { node, npm } = current;
  const { name, version } = current.package;
  const { platform, release } = current.os;

  console.log(`Bundled on: ${describe(bundle)}`);
  // console.log(`Running on: ${describe(current)}`);

  if (bundle.package.version !== version) {
    console.warn(
      `${colors.yellow('WARNING')}: Bundle was created with ${
        bundle.package.name
      } ${colors.cyan(bundle.package.version)}, but this is ${colors.green(
        version,
      )}.`,
    );
  }

  if (bundle.node !== node) {
    console.warn(
      `${colors.yellow('WARNING')}: Bundle was created with Node ${colors.cyan(
        bundle.node,
      )} but this is ${colors.green(node)}.`,
    );
  }

  if (bundle.npm !== npm) {
    console.warn(
      `${colors.yellow('WARNING')}: Bundle was created with npm ${colors.cyan(
        bundle.npm,
      )} but this is ${colors.green(npm)}.`,
    );
  }

  if (bundle.os.platform !== platform || bundle.os.release !== release) {
    console.warn(
      `${colors.yellow('WARNING')}: Bundle was created on ${colors.cyan(
        bundle.os.platform,
      )}-${colors.cyan(bundle.os.release)} but this is ${colors.green(
        platform,
      )}-${colors.green(release)}.`,
    );
  }

  if (
    bundle.package.version !== version ||
    bundle.node !== node ||
    bundle.npm !== npm
  ) {
    console.error(
      `${colors.red(
        'ERROR',
      )}: Bundle does not match the version of the ${name}, node, or npm. This may cause bundled installation to fail. Please ensure bundle is created with the same version as the installation target.`,
    );

    console.error(`${colors.red('×')} Offline install bundle appears invalid.`);
  } else {
    console.log(`${colors.green('√')} Offline install bundle appears valid.`);
  }
}

async function write() {
  try {
    const bundle = await info();

    const data = JSON.stringify(bundle, null, '  ');

    await writeFile(path, data);

    return bundle;
  } catch (error) {
    console.error(`Error writing bundle:`, error);
  }
}

async function read() {
  try {
    const data = await readFile(path);

    const bundle = JSON.parse(data);

    return bundle;
  } catch (error) {
    console.warn(
      `${colors.yellow(
        'WARNING',
      )}: Bundle info file either not found or corrupt. If internet access is available, this is not an issue. For offline installation, please ensure this package is bundled with it's dependencies prior to being transferred to the installation target.`,
    );
    // console.warn(`Bundle info file (${path}) error: ${error.message}`);
  }
}

module.exports = { info, describe, compare, read, write };
