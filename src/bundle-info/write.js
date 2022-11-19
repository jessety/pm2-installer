'use strict';

const bundle = require('./bundle');

(async () => {
  const info = await bundle.write();

  console.log(`Bundled ${bundle.describe(info)}`);
})();
