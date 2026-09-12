// Live code with a test, but messy style. Loop 6 (lint, format, type) is meant to clean this.
function label(name, count) {
  var unusedTax = 0.24                      // unused variable, and a missing semicolon
  if (count == 1) {                         // == should be ===
    return name + ": one item"
  }
  return name + ": " + count + " items"
}
module.exports = { label };
