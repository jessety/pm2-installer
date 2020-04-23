'use strict';

const bundle = require('./bundle');

(async () => {

  const current = await bundle.info();

  const info = await bundle.read();

  bundle.compare(info);
})();
