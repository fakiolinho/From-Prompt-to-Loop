#!/usr/bin/env node
// A dependency-free playground for the AI/ML loops (20-26).
// Run:  node loops.js <20|21|22|23|24|25|26|all>
// Each check finds the real problem seeded in this project. Simplified, instant, offline so you can
// follow along; the pack loops run the same checks in CI against your real prompts, models and data.
const fs = require('fs'), path = require('path'), crypto = require('crypto');
const D = __dirname;
const read = f => fs.readFileSync(path.join(D, f), 'utf8');
const readJSON = f => JSON.parse(read(f));
const jsonl = f => read(f).trim().split('\n').filter(Boolean).map(l => JSON.parse(l));
const { classify } = require('./classify');
const { guardAllows } = require('./guard');

function loop20() {
  console.log('Loop 20. RAG knowledge base sync   (is the index stale vs the source docs?)');
  const byFile = Object.fromEntries(readJSON('index.json').indexed.map(e => [e.file, e.hash]));
  let work = 0;
  for (const f of fs.readdirSync(path.join(D, 'docs')).filter(f => f.endsWith('.md'))) {
    const h = crypto.createHash('md5').update(read(path.join('docs', f))).digest('hex').slice(0, 12);
    if (!byFile[f]) { console.log(`  NEW      docs/${f}  (not in the index)`); work = 1; }
    else if (byFile[f] !== h) { console.log(`  CHANGED  docs/${f}  (index hash is stale)`); work = 1; }
  }
  console.log(work ? '  The loop reindexes these and opens a PR.' : '  index is in sync');
  return work;
}

function loop21() {
  console.log('Loop 21. Structured output conformance   (do model outputs match the schema?)');
  const schema = readJSON('schema.json');
  let bad = 0;
  jsonl('outputs.jsonl').forEach((r, i) => {
    const errs = [];
    for (const [k, spec] of Object.entries(schema.properties)) {
      if (schema.required.includes(k) && !(k in r)) { errs.push(`missing ${k}`); continue; }
      if (!(k in r)) continue;
      if (spec.type === 'string' && typeof r[k] !== 'string') errs.push(`${k} not a string`);
      if (spec.type === 'array' && !Array.isArray(r[k])) errs.push(`${k} not an array`);
      if (spec.type === 'number') {
        if (typeof r[k] !== 'number') errs.push(`${k} not a number`);
        else if ((spec.min != null && r[k] < spec.min) || (spec.max != null && r[k] > spec.max)) errs.push(`${k} out of range`);
      }
    }
    if (errs.length) { console.log(`  output ${i}: ${errs.join(', ')}`); bad++; }
  });
  console.log(bad ? `  ${bad} nonconforming. The loop adds a repair or validation step, then re-checks.` : '  all outputs conform');
  return bad ? 1 : 0;
}

function evalAccuracy() {
  const cases = readJSON('evals/cases.json');
  let p = 0; for (const c of cases) if (classify(c.utterance) === c.intent) p++;
  return +(p / cases.length).toFixed(4);
}

function loop22() {
  console.log('Loop 22. Model version upgrade testing   (evaluate a new version before switching)');
  const m = readJSON('models.json');
  if (m.inUse === m.available) { console.log('  on the latest version'); return 0; }
  const acc = evalAccuracy(), base = readJSON('baseline.json').accuracy;
  console.log(`  upgrade available: ${m.inUse} -> ${m.available}`);
  console.log(`  candidate scores ${acc} vs baseline ${base} on the eval set`);
  console.log(acc >= base ? '  passes. The loop opens a PR to switch; it never auto-switches.' : '  regresses. The loop holds the upgrade and opens an issue.');
  return 1;
}

function loop23() {
  console.log('Loop 23. Golden set growth from production failures   (add real misses to the eval set)');
  const have = new Set(readJSON('evals/cases.json').map(c => c.utterance.toLowerCase()));
  const missing = jsonl('production-failures.jsonl').filter(f => !have.has(f.utterance.toLowerCase()));
  missing.forEach(f => console.log(`  ADD  "${f.utterance}" -> ${f.expected}`));
  console.log(missing.length ? `  ${missing.length} failure(s) not in the set. The loop adds them so the same miss can't return.` : '  golden set covers all logged failures');
  return missing.length ? 1 : 0;
}

function loop24() {
  console.log('Loop 24. Prompt cost and routing optimisation   (over-budget or mis-routed calls?)');
  const BUDGET = 0.05; let work = 0;
  for (const r of jsonl('traces.jsonl')) {
    if (r.costUsd > BUDGET) { console.log(`  OVER BUDGET  ${r.id}  $${r.costUsd} (cap $${BUDGET})`); work = 1; }
    if (/expensive|big|opus|gpt-5/.test(r.model) && ['greeting', 'farewell'].includes(r.task)) {
      console.log(`  MIS-ROUTED   ${r.id}  ${r.model} for a ${r.task}, use a small model`); work = 1;
    }
  }
  console.log(work ? '  The loop proposes routing or prompt changes behind a PR.' : '  spend and routing look fine');
  return work;
}

function loop25() {
  console.log('Loop 25. Safety and red-team regression   (does any unsafe prompt get through?)');
  console.log('  (the guard here is a stand-in; the point is the red-team set never regresses)');
  let leaked = 0;
  for (const c of readJSON('redteam.json')) if (c.mustRefuse && guardAllows(c.prompt)) { console.log(`  LEAK  "${c.prompt}"  allowed but must be refused`); leaked++; }
  console.log(leaked ? `  ${leaked} regression(s). The loop blocks the change and opens an issue. It never weakens the set.` : '  red-team set holds, nothing leaks');
  return leaked ? 1 : 0;
}

function loop26() {
  console.log('Loop 26. Data quality and drift monitoring   (schema, nulls, distribution)');
  const base = readJSON('data/baseline.json'), cur = readJSON('data/current.json');
  let work = 0;
  for (const k of Object.keys(base[0])) if (!(k in cur[0])) { console.log(`  SCHEMA  field "${k}" disappeared`); work = 1; }
  const nullRate = a => a.filter(r => r.age == null).length / a.length;
  const bn = nullRate(base), cn = nullRate(cur);
  if (cn - bn > 0.2) { console.log(`  NULLS   age null rate ${(bn * 100).toFixed(0)}% -> ${(cn * 100).toFixed(0)}%`); work = 1; }
  const dist = a => a.reduce((m, r) => (m[r.country] = (m[r.country] || 0) + 1, m), {});
  const bd = dist(base), cd = dist(cur);
  for (const c of new Set([...Object.keys(bd), ...Object.keys(cd)])) {
    const bp = (bd[c] || 0) / base.length, cp = (cd[c] || 0) / cur.length;
    if (Math.abs(bp - cp) > 0.3) { console.log(`  DRIFT   country "${c}" ${(bp * 100).toFixed(0)}% -> ${(cp * 100).toFixed(0)}%`); work = 1; }
  }
  console.log(work ? '  The loop flags this before the data trains or evaluates anything.' : '  data looks stable');
  return work;
}

const map = { 20: loop20, 21: loop21, 22: loop22, 23: loop23, 24: loop24, 25: loop25, 26: loop26 };
const arg = process.argv[2];
if (arg === 'all') {
  let work = 0;
  for (const n of [20, 21, 22, 23, 24, 25, 26]) { work += map[n](); console.log(); }
  console.log(work ? `${work} loop(s) found work in this project.` : 'nothing to do.');
  process.exit(work ? 1 : 0);
} else if (map[arg]) { process.exit(map[arg]()); }
else { console.log('usage: node loops.js <20|21|22|23|24|25|26|all>'); process.exit(1); }
