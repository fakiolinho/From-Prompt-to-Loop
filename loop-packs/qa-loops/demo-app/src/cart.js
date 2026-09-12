function sumItems(items) { return items.reduce((a, i) => a + i.price * i.qty, 0); }
// Bug: no clamp on pct, so a discount over 100% produces a negative total. BUG-101 reports it.
function applyDiscount(total, pct) { return total - (total * pct) / 100; }
module.exports = { sumItems, applyDiscount };
