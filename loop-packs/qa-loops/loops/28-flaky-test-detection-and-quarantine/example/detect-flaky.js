// Runs every test many times and measures its pass rate.
// healthy = always passes, broken = never passes, FLAKY = sometimes.
// Tests listed in quarantine.json still RUN (so we keep measuring them) but report as
// QUARANTINED and do NOT fail the build. Quarantine is how a flaky test stops blocking the
// team without being deleted or hidden, and it is how this suite reaches green.
const fs = require('fs');
const path = require('path');

const N = 20;
const dir = path.join(__dirname, 'tests');
const files = fs.readdirSync(dir).filter(f => f.endsWith('.test.js'));

let quarantined = [];
try {
  quarantined = JSON.parse(fs.readFileSync(path.join(__dirname, 'quarantine.json'), 'utf8'))
    .quarantined.map(q => q.name);
} catch (_) { /* no quarantine file yet, treat as none */ }

let problems = 0;
const report = [];
for (const f of files) {
  const t = require(path.join(dir, f));
  let pass = 0;
  for (let i = 0; i < N; i++) { try { t.run(); pass++; } catch (_) {} }
  const rate = pass / N;
  let status = rate === 1 ? 'healthy' : rate === 0 ? 'broken' : 'FLAKY';
  if (status !== 'healthy' && quarantined.includes(t.name)) {
    status = 'QUARANTINED';            // measured, but does not block the build
  } else if (status !== 'healthy') {
    problems++;
  }
  report.push(`  ${status.padEnd(11)} ${t.name}  (${pass}/${N} passes)`);
}
console.log(`ran each test ${N}x`);
report.forEach(r => console.log(r));

if (problems) {
  console.error(`${problems} unquarantined test(s) need quarantine or a fix. Not green.`);
  process.exit(1);
}
console.log('all tests stable or quarantined. green.');
