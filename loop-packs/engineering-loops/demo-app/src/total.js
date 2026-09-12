// Sums line items. Clean, and it has a test (src/total.test.js).
function sumItems(items) {
  return items.reduce((acc, item) => acc + item.price * item.qty, 0);
}
module.exports = { sumItems };
