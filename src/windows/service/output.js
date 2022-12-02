'use strict';

const fs = require('fs');
const path = require('path');

// Pull references to the console functions, because PM2 replaces the global console object after we start it
const { log: consoleLog, warn: consoleWarn, error: consoleError } = console;

/**
 * Flatten parameters of any type into a string
 * @param  {...any} params
 */
function flatten(...params) {
  const flattened = params.map((item) => {
    if (['string', 'boolean', 'number'].includes(typeof item)) {
      return item;
    }

    if (item instanceof Error) {
      item = {
        ...item,
        message: item.message,
        stack: item.stack,
        name: item.name,
      };
    }

    try {
      return JSON.stringify(item, null, '  ');
    } catch (error) {
      return '[Unserializable object]';
    }
  });

  return flattened.join(' ');
}

/**
 * Write a message to the log file, if we can discern where the log file is supposed to be
 * @param {string} type - LOG, WARNING, or ERROR. Or anything else, really.
 * @param {boolean} date - whether to write the timestamp to the log file or not
 * @param  {...any} out
 */
function write(type = 'LOG', date = true, ...out) {
  const { PM2_SERVICE_DIRECTORY } = process.env;

  if (PM2_SERVICE_DIRECTORY === undefined || PM2_SERVICE_DIRECTORY === '') {
    return;
  }

  const filepath = path.join(PM2_SERVICE_DIRECTORY, 'service.log');

  let string = `\n`;

  if (date === true) {
    string += `${new Date().toLocaleString()}: `;
  }

  if (type !== 'LOG') {
    string += `${type}: `;
  }
  string += flatten(...out);

  try {
    fs.appendFileSync(filepath, string);
  } catch (error) {
    consoleError('Failed to write to log file:', error);
  }
}

const log = (...out) => {
  consoleLog('pm2-service:', ...out);
  write('LOG', true, ...out);
};

const warn = (...out) => {
  consoleWarn('pm2-service:', ...out);
  write('WARNING', true, ...out);
};

const error = (...out) => {
  consoleError('pm2-service:', ...out);
  write('ERROR', true, ...out);
};

// Replace the console functions so we can write output from pm2 to our log file as well

console.log = (...out) => {
  consoleLog(...out);
  write('LOG', false, ...out);
};

console.warn = (...out) => {
  consoleWarn(...out);
  write('WARNING', false, ...out);
};

console.error = (...out) => {
  consoleError(...out);
  write('ERROR', false, ...out);
};

module.exports = { log, warn, error };
