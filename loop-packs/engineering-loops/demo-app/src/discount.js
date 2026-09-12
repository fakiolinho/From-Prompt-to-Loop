// Applies a percentage discount. This is live code (index.js uses it) but has NO test.
// Loop 4 (test backfill) is meant to notice exactly this.
function applyDiscount(total, pct) {
  return total - (total * pct) / 100;
}
module.exports = { applyDiscount };
