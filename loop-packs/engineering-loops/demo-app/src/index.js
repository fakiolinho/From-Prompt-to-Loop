// Entry point. Uses total, discount, messy, and the `ms` dependency.
const ms = require('ms');
const { sumItems } = require('./total');
const { applyDiscount } = require('./discount');
const { label } = require('./messy');

const cart = [{ price: 10, qty: 2 }, { price: 5, qty: 1 }];
const total = sumItems(cart);
const final = applyDiscount(total, 10);

console.log(label('cart', cart.length));
console.log('total', total, 'after 10% off', final);
console.log('rendered in', ms(1234));
