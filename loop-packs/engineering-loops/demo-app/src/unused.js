// Dead code: this is exported but nothing imports it. Loop 5 (dead code) is meant to find it.
function legacyRound(n) {
  return Math.round(n * 100) / 100;
}
module.exports = { legacyRound };
