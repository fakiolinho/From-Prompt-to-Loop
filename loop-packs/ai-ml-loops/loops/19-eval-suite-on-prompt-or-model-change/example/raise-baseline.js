// Ratchets baseline.json up to the current accuracy, and only when the run is an improvement.
// It never lowers the baseline. In CI this runs on an improvement and the change goes out as a
// PR you approve. Locally, run it to see the full cycle without an agent.
const fs = require('fs');
const path = require('path');
const { classify } = require('./src/classify');

const cases = JSON.parse(fs.readFileSync(path.join(__dirname, 'evals', 'cases.json'), 'utf8'));
const bf = path.join(__dirname, 'baseline.json');
const baseline = JSON.parse(fs.readFileSync(bf, 'utf8')).accuracy;

let pass = 0;
for (const c of cases) if (classify(c.utterance) === c.intent) pass++;
const acc = +(pass / cases.length).toFixed(4);

if (acc <= baseline) {
  console.log(`no change: accuracy ${acc} is not above baseline ${baseline}.`);
  process.exit(0);
}
fs.writeFileSync(bf, JSON.stringify({ accuracy: acc }, null, 2) + '\n');
console.log(`baseline raised ${baseline} -> ${acc}. Open a PR with this change for review.`);
