'use strict';

const bundle = require('./bundle');

(async () => {
  const current = await bundle.info();
  const bundled = await bundle.read();

  bundle.compare(bundled, current);
})();
