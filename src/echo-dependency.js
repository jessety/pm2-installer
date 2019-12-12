'use strict';

// Print the version of a specified dependency to the console

const { dependencies } = require('../package.json');

let [identifier] = process.argv.slice(2);

if (identifier === undefined) {
  // No can do.
  process.exit();
}

// The dependencies we use are: 'pm2', 'pm2-windows-service', or 'pm2-logrotate'

// pm2-windows-service is unmaintained, so we're using a fork
if (identifier === 'pm2-windows-service') {
  identifier = '@innomizetech/pm2-windows-service';
}

if (dependencies[identifier] === undefined) {
  // Nope.
  process.exit();
}

const version = dependencies[identifier].replace(/\^|~/g, '');

console.log(`${identifier}@${version}`);
