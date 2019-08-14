'use strict';

const bundle = require('./bundle');

(async () => {

  const current = await bundle.info();

  console.log(`Running on: ${bundle.describe(current)}`);

  const info = await bundle.read();

  bundle.compare(info);
})();
