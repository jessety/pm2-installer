#!/usr/bin/env node

'use strict';

const { strip } = require('./util');

const [type] = process.argv.slice(2);

if (
  type !== undefined &&
  ['dependencies', 'devDependencies', 'all'].includes(type) === false
) {
  console.error(`Invalid dependency type: ${type}`);
}

if (type === 'dependencies' || type === 'devDependencies') {
  strip(type);
} else {
  strip('dependencies');
  strip('devDependencies');
}
