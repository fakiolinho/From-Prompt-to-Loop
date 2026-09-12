const assert = require('assert');
const { label } = require('./messy');
assert.strictEqual(label('cart', 1), 'cart: one item');
assert.strictEqual(label('cart', 3), 'cart: 3 items');
console.log('messy.test.js passed');
