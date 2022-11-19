#!/usr/bin/env node

'use strict';

const https = require('https');

const host = 'registry.npmjs.org';

console.log('Checking connectivity to the npm registry..');

const request = https.request(
  { host, path: '/', timeout: 2500 },
  (response) => {
    if (response.statusCode !== 200) {
      console.log(
        `Received unexpected status code from ${host}: ${response.statusCode}`,
      );
      process.exit(1);
    }

    const chunks = [];

    response.on('data', (chunk) => chunks.push(chunk));

    response.on('end', () => {
      try {
        const string = Buffer.concat(chunks).toString();

        const object = JSON.parse(string);

        if (object.db_name !== 'registry') {
          console.log(`Received unexpected response from ${host}:`, object);

          process.exit(1);
        }

        console.log(`Successfully connected to ${host}.`);

        process.exit(0);
      } catch (error) {
        console.log(
          `Received unexpected response from ${host}: ${error.message}`,
        );
        process.exit(1);
      }
    });
  },
);

request.on('timeout', () => request.abort());

request.on('error', (error) => {
  console.log(`Could not connect to ${host}: ${error.message}`);
  process.exit(1);
});

request.end();
