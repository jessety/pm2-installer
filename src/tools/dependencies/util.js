'use strict';

const { readFileSync, writeFileSync, existsSync } = require('fs');
const { join } = require('path');

/**
 * Remove dependencies from package.json and place them in a separate file
 */
function strip(type) {
  const paths = getPaths();
  const depsPath = paths[type];

  if (existsSync(paths.pkg) === false) {
    console.error(`No package.json file found. Aborting..`);
    process.exit(1);
  }

  try {
    const pkgRaw = readFileSync(paths.pkg, 'utf8');

    const pkg = JSON.parse(pkgRaw);
    const deps = pkg[type];
    delete pkg[type];

    writeFileSync(paths.pkg, `${JSON.stringify(pkg, null, 2)}\n`, 'utf8');
    writeFileSync(depsPath, JSON.stringify(deps, null, 2), 'utf8');
  } catch (error) {
    console.warn(
      `An error has occurred while stripping ${type} dependencies from ${paths.pkg}: ${error.message}\nProceeding..`,
    );
    console.warn(`This may not be fatal. Proceeding..`);
    process.exit(0);
  }
}

/**
 * Add dependencies to package.json from a separate file
 */
function restore(type) {
  const paths = getPaths();
  const depsPath = paths[type];

  if (existsSync(depsPath) === false) {
    console.error(`No ${type} file found. Aborting..`);
    process.exit(0);
  }

  try {
    const pkgRaw = readFileSync(paths.pkg, 'utf8');
    const depsRaw = readFileSync(depsPath, 'utf8');

    const pkg = JSON.parse(pkgRaw);
    const deps = JSON.parse(depsRaw);

    pkg[type] = deps;

    writeFileSync(paths.pkg, `${JSON.stringify(pkg, null, 2)}\n`, 'utf8');
  } catch (error) {
    console.warn(
      `An error has occurred while restoring ${type} dependencies to ${paths.pkg}: ${error.message}\nProceeding..`,
    );
    console.warn(`This may not be fatal. Proceeding..`);
    process.exit(0);
  }
}

/**
 * Return paths for package.json and dependencies files
 */
function getPaths() {
  const up = '../../../';

  const pkg = join(__dirname, up, 'package.json');
  const dependencies = join(__dirname, up, `package.dependencies.json`);
  const devDependencies = join(__dirname, up, `package.devDependencies.json`);
  const peerDependencies = join(__dirname, up, `package.peerDependencies.json`);

  return { pkg, dependencies, devDependencies, peerDependencies };
}

module.exports = {
  restore,
  strip,
};
