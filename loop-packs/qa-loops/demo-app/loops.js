#!/usr/bin/env node
// A dependency-free playground for the QA loops 27, 30, 33, 34.
// Run:  node loops.js <27|30|33|34|all>
// Each check finds the real problem seeded here. Simplified, instant, offline so you can follow
// along; the pack loops run the same kind of check in CI. (Loop 28, flaky detection, has its own
// runnable example in loops/28-.../example.)
const fs = require('fs'), path = require('path');
const D = __dirname;
const read = f => fs.readFileSync(path.join(D, f), 'utf8');
const readJSON = f => JSON.parse(read(f));

function loop27() {
  console.log('Loop 27. Bug report to failing test   (reproduce before you fix)');
  const cart = require('./src/cart');
  const bugsDir = path.join(D, 'bugs');
  const tests = fs.existsSync(path.join(D, 'tests')) ? fs.readdirSync(path.join(D, 'tests')) : [];
  let work = 0;
  for (const f of fs.readdirSync(bugsDir).filter(f => f.endsWith('.json'))) {
    const b = JSON.parse(fs.readFileSync(path.join(bugsDir, f), 'utf8'));
    const guarded = tests.some(t => t.includes(b.id));
    if (guarded) continue;
    const actual = cart[b.fn](...b.args);
    const reproduced = actual !== b.expected;
    console.log(`  ${b.id}  ${b.title}`);
    console.log(`    ${b.fn}(${b.args.join(', ')}) = ${actual}, expected ${b.expected}` + (reproduced ? '  REPRODUCED' : ''));
    console.log('    no test guards this yet. The loop writes a failing test first, then the fix makes it pass.');
    work = 1;
  }
  if (!work) console.log('  every open bug has a reproducing test');
  return work;
}

function loop30() {
  console.log('Loop 30. Test data and fixtures   (do fixtures still match the schema?)');
  const schema = readJSON('schema.json');
  let bad = 0;
  readJSON('fixtures.json').forEach((r, i) => {
    const errs = [];
    for (const [k, spec] of Object.entries(schema.properties)) {
      if (schema.required.includes(k) && !(k in r)) { errs.push(`missing ${k}`); continue; }
      if (!(k in r)) continue;
      if (spec.type === 'boolean' && typeof r[k] !== 'boolean') errs.push(`${k} not a boolean`);
      if (spec.type === 'string' && typeof r[k] !== 'string') errs.push(`${k} not a string`);
      if (spec.type === 'number' && typeof r[k] !== 'number') errs.push(`${k} not a number`);
    }
    if (errs.length) { console.log(`  record ${i} (id ${r.id ?? '?'}): ${errs.join(', ')}`); bad++; }
  });
  console.log(bad ? `  ${bad} fixture(s) drifted from the schema. The loop regenerates or repairs them behind a PR.` : '  fixtures match the schema');
  return bad ? 1 : 0;
}

function grid(f) { return read(path.join('screenshots', f)).trim().split('\n').map(r => r.trim().split(/\s+/).map(Number)); }
function loop33() {
  console.log('Loop 33. Visual regression triage   (did the screenshot change?)');
  const a = grid('baseline.txt'), b = grid('current.txt');
  let diff = 0, total = 0;
  const rows = Math.max(a.length, b.length);
  for (let y = 0; y < rows; y++) {
    const ra = a[y] || [], rb = b[y] || [];
    const cols = Math.max(ra.length, rb.length);
    for (let x = 0; x < cols; x++) { total++; if ((ra[x] ?? null) !== (rb[x] ?? null)) diff++; }
  }
  const pct = (diff / total) * 100;
  if (pct < 1) { console.log(`  no meaningful change (${pct.toFixed(1)}%)`); return 0; }
  console.log(`  CHANGED  ${diff}/${total} pixels (${pct.toFixed(1)}%) differ from the baseline`);
  console.log('  The loop triages: a real change updates the baseline behind a PR; a flake opens a bug. It never blind-accepts.');
  return 1;
}

function loop34() {
  console.log('Loop 34. E2e coverage from real user flows   (are the top journeys tested?)');
  const flows = readJSON('flows.json').flows.sort((x, y) => y.weight - x.weight);
  const covered = new Set(readJSON('e2e-manifest.json').covered);
  const gaps = flows.filter(f => !covered.has(f.name));
  gaps.forEach(g => console.log(`  UNCOVERED  ${g.name}  (${(g.weight * 100).toFixed(0)}% of real traffic)`));
  console.log(gaps.length ? '  The loop drafts an e2e test for the highest-traffic gap first, behind a PR.' : '  top flows are covered');
  return gaps.length ? 1 : 0;
}

const map = { 27: loop27, 30: loop30, 33: loop33, 34: loop34 };
const arg = process.argv[2];
if (arg === 'all') {
  let work = 0;
  for (const n of [27, 30, 33, 34]) { work += map[n](); console.log(); }
  console.log(work ? `${work} loop(s) found work in this project.` : 'nothing to do.');
  process.exit(work ? 1 : 0);
} else if (map[arg]) { process.exit(map[arg]()); }
else { console.log('usage: node loops.js <27|30|33|34|all>'); process.exit(1); }
