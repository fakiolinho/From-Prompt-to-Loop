// The eval harness. Scores the classifier over every case and compares to the baseline.
// Three outcomes, three exit codes, so the workflow can act on each:
//   regression (accuracy < baseline)   -> exit 1: list failing cases, open an issue.
//   at baseline (accuracy == baseline) -> exit 0: nothing to do.
//   improvement (accuracy > baseline)  -> exit 3: the baseline can be ratcheted up.
const fs = require('fs');
const path = require('path');
const { classify } = require('./src/classify');

const cases = JSON.parse(fs.readFileSync(path.join(__dirname, 'evals', 'cases.json'), 'utf8'));
const baseline = JSON.parse(fs.readFileSync(path.join(__dirname, 'baseline.json'), 'utf8')).accuracy;

let pass = 0;
const misses = [];
for (const c of cases) {
  const got = classify(c.utterance);
  if (got === c.intent) pass++;
  else misses.push(`  MISS "${c.utterance}" -> got ${got}, want ${c.intent}`);
}
const acc = +(pass / cases.length).toFixed(4);
console.log(`accuracy ${acc} on ${cases.length} cases (baseline ${baseline})`);
misses.forEach(m => console.log(m));

if (acc < baseline) {
  console.error(`REGRESSION: ${acc} < baseline ${baseline}. Not shipping. Open an issue with the misses above.`);
  process.exit(1);
}
if (acc > baseline) {
  console.log(`IMPROVEMENT: ${acc} above baseline ${baseline}. Ratchet it with: npm run raise-baseline (opens a PR in CI).`);
  process.exit(3);
}
console.log('at baseline. nothing to do.');
process.exit(0);
