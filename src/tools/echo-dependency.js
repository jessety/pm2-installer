'use strict';

// Print the version of a specified dependency to the console

const pkg = require('../../package.json');

let [identifier, type] = process.argv.slice(2);

if (type === undefined) {
  type = 'global';
}

let dependencies = {};

if (type === 'windows') {
  dependencies = pkg.windowsDependencies;
} else if (type === 'global') {
  dependencies = pkg.globalDependencies;
} else if (type === 'dev') {
  dependencies = pkg.devDependencies;
} else {
  process.exit();
}

if (identifier === undefined) {
  // No can do.
  process.exit();
}

// The global dependencies we need are: 'pm2' and 'pm2-logrotate'

if (dependencies[identifier] === undefined) {
  // Nope.
  process.exit();
}

const version = dependencies[identifier].replace(/\^|~/g, '');

console.log(`${identifier}@${version}`);
