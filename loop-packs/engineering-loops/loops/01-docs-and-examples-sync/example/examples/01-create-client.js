const { createClient } = require('../src');

const client = createClient({ key: 'sk-demo' });
console.log('client ready for', client.baseUrl);

module.exports = client;
