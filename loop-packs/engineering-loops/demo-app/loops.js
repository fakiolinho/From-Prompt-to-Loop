#!/usr/bin/env node
// A tiny, dependency-free playground for the engineering loops.
// Run:  node loops.js <2|4|5|6|7|all>
// Each check finds the real problem seeded in this project and prints what the loop would act on.
// These are simplified, instant, offline versions of the pack's checks so you can follow along
// with zero setup. The real pack loops use the tools named under each check.
const fs = require('fs');
const path = require('path');
const cp = require('child_process');

const SRC = path.join(__dirname, 'src');
const srcFiles = fs.readdirSync(SRC).filter(f => f.endsWith('.js'));
const code = f => fs.readFileSync(path.join(SRC, f), 'utf8');

// Which local modules get imported anywhere (so we can tell live code from dead code).
const imported = new Set();
for (const f of srcFiles) {
  const m = code(f).matchAll(/require\(['"]\.\/([\w-]+)['"]\)|from ['"]\.\/([\w-]+)['"]/g);
  for (const x of m) imported.add((x[1] || x[2]) + '.js');
}

function loop2() {
  console.log('Loop 2. Dependency upgrades   (pack check: `npm outdated`)');
  if (!fs.existsSync(path.join(__dirname, 'node_modules'))) {
    console.log('  Run `npm install` once, then `npm run loop2` to see real version data.');
    const deps = JSON.parse(code0()).dependencies || {};
    console.log('  Pinned dependencies in package.json:', Object.entries(deps).map(([k, v]) => `${k}@${v}`).join(', '));
    return 1;
  }
  try { cp.execSync('npm outdated', { cwd: __dirname, stdio: 'inherit' }); console.log('  all dependencies current'); return 0; }
  catch {
    console.log('  ^ ms can move inside its range (Wanted 2.1.3), so the loop bumps it, runs the');
    console.log('    verify command, and opens a PR. is-odd can only go to a major, so the loop');
    console.log('    leaves it alone and opens an issue. Latest is not always safe, or even newer.');
    return 1;
  }
}
const code0 = () => fs.readFileSync(path.join(__dirname, 'package.json'), 'utf8');

function loop4() {
  console.log('Loop 4. Test backfill on changed code   (pack check: git diff for untested changes)');
  const live = srcFiles.filter(f => !f.endsWith('.test.js') && f !== 'index.js' && imported.has(f));
  const untested = live.filter(f => !srcFiles.includes(f.replace('.js', '.test.js')));
  if (!untested.length) { console.log('  every live module has a test'); return 0; }
  untested.forEach(f => console.log(`  NO TEST  src/${f}  (live code, imported, but no src/${f.replace('.js', '.test.js')})`));
  console.log('  The loop would write a focused test that passes against current behaviour.');
  return 1;
}

function loop5() {
  console.log('Loop 5. Dead code and unused dependencies   (pack check: `knip`)');
  let work = 0;
  const dead = srcFiles.filter(f => !f.endsWith('.test.js') && f !== 'index.js' && !imported.has(f));
  dead.forEach(f => { console.log(`  DEAD FILE   src/${f}  (exported but nothing imports it)`); work = 1; });
  const deps = Object.keys(JSON.parse(code0()).dependencies || {});
  const allSrc = srcFiles.map(code).join('\n');
  const unusedDeps = deps.filter(d => !new RegExp(`['"]${d}['"]`).test(allSrc));
  unusedDeps.forEach(d => { console.log(`  UNUSED DEP  ${d}  (in package.json, never imported)`); work = 1; });
  if (!work) console.log('  no dead code or unused dependencies');
  else {
    console.log('  The loop lists these for a human and opens an issue. It never deletes.');
    console.log('  A green build does not prove a cut was safe, and deleting a test makes the');
    console.log('  suite pass more easily. That is why loop 5 flags rather than ships.');
  }
  return work;
}

function loop6() {
  console.log('Loop 6. Lint, format, and type fixes   (pack check: eslint + prettier + tsc)');
  let work = 0;
  for (const f of srcFiles.filter(f => !f.endsWith('.test.js'))) {
    const src = code(f);
    const hits = [];
    if (/[^=!]==[^=]/.test(src)) hits.push('uses == (should be ===)');
    if (/\bvar\s/.test(src)) hits.push('uses var (should be const/let)');
    for (const m of src.matchAll(/\b(?:var|const|let)\s+(\w+)\s*=/g)) {
      const name = m[1];
      if ((src.match(new RegExp(`\\b${name}\\b`, 'g')) || []).length === 1) hits.push(`unused variable "${name}"`);
    }
    if (/[ \t]+$/m.test(src)) hits.push('trailing whitespace');
    if (hits.length) { console.log(`  src/${f}: ${hits.join('; ')}`); work = 1; }
  }
  if (!work) console.log('  clean');
  else console.log('  The loop would auto-fix the mechanical issues; a type error it cannot fix safely it flags.');
  return work;
}

function loop7() {
  console.log('Loop 7. Release notes and changelog   (pack check: git log since last tag)');
  const version = JSON.parse(code0()).version;
  const ch = fs.readFileSync(path.join(__dirname, 'CHANGELOG.md'), 'utf8');
  const top = (ch.match(/##\s*([\d.]+)/) || [])[1];
  if (top === version) { console.log('  changelog is up to date'); return 0; }
  console.log(`  BEHIND  package.json is ${version} but the changelog tops out at ${top}.`);
  console.log('  The loop would write the entries for the new version from the commit log.');
  return 1;
}

const map = { 2: loop2, 4: loop4, 5: loop5, 6: loop6, 7: loop7 };
const arg = process.argv[2];
if (arg === 'all') {
  let work = 0;
  for (const n of [2, 4, 5, 6, 7]) { work += map[n](); console.log(); }
  console.log(work ? `${work} loop(s) found work in this project.` : 'nothing to do.');
  process.exit(work ? 1 : 0);
} else if (map[arg]) {
  process.exit(map[arg]());
} else {
  console.log('usage: node loops.js <2|4|5|6|7|all>');
  process.exit(1);
}
