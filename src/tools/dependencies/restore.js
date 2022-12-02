#!/usr/bin/env node

'use strict';

const { restore } = require('./util');

const [type] = process.argv.slice(2);

if (
  type !== undefined &&
  ['dependencies', 'devDependencies', 'all'].includes(type) === false
) {
  console.error(`Invalid dependency type: ${type}`);
}

if (type === 'dependencies' || type === 'devDependencies') {
  restore(type);
} else {
  restore('dependencies');
  restore('devDependencies');
}
