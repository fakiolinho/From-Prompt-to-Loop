const assert = require('assert');
const { sumItems } = require('./total');
assert.strictEqual(sumItems([{ price: 10, qty: 2 }, { price: 5, qty: 1 }]), 25);
assert.strictEqual(sumItems([]), 0);
console.log('total.test.js passed');
