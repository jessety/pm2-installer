'use strict';

const colors = {
  black: '\u001b[30m',
  red: '\u001b[31m',
  green: '\u001b[32m',
  yellow: '\u001b[33m',
  blue: '\u001b[34m',
  magenta: '\u001b[35m',
  cyan: '\u001b[36m',
  white: '\u001b[37m'
};

const reset = '\u001b[0m';

for (const [name, value] of Object.entries(colors)) {

  if (process.stdout.isTTY === true) {

    module.exports[name] = (...out) => `${value}${out.join(' ')}${reset}`;

  } else {

    module.exports[name] = (...out) => out.join(' ');
  }
}
