const { createClient } = require('../src');

const client = createClient({ key: 'sk-demo' });
const res = client.send('hello world');
if (res.status !== 'sent') throw new Error('expected status sent');
console.log('sent message', res.id);
