#!/usr/bin/env node
// Issue triage: suggests labels, a route, and whether a reproduction is missing.
// Run:  node triage.js <issue-file>   (in CI: gh issue view <n> --json title,body)
// Rule-based and objective. The agent applies the labels via gh; this shows the decision.
const fs = require('fs');
const path = require('path');
const text = fs.readFileSync(process.argv[2] || path.join(__dirname, 'sample-issue.md'), 'utf8');
const t = text.toLowerCase();
const has = (...w) => w.some(x => x === '?' ? t.includes('?') : new RegExp('\\b' + x.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '\\b').test(t));

const area =
  has('checkout', 'payment', 'discount', 'charge', 'billing') ? 'area:payments' :
  has('login', 'signup', 'password', 'token', 'auth') ? 'area:auth' :
  has('endpoint', 'api', '500', 'timeout', 'server') ? 'area:backend' :
  has('page', 'button', 'layout', 'css', 'screen') ? 'area:frontend' : 'area:unknown';

const type =
  has('crash', 'error', 'broken', 'blank', 'fails', 'wrong', 'does not', "doesn't") ? 'type:bug' :
  has('add', 'feature', 'would be nice', 'support for') ? 'type:feature' :
  has('how do', 'how can', '?') ? 'type:question' : 'type:bug';

const priority =
  has('crash', 'data loss', 'security', 'losing sales', 'revenue', 'payment', 'cannot', 'down') ? 'priority:high' : 'priority:medium';

const team = { 'area:payments': 'payments', 'area:auth': 'identity', 'area:backend': 'platform', 'area:frontend': 'web', 'area:unknown': 'triage' }[area];
const hasRepro = /steps to reproduce|reproduc|repro\b|^\s*1\./im.test(text);

console.log('Triage (pack loop 9). The loop applies labels and routes; it never closes or codes.');
console.log('  labels:  ' + [type, area, priority].join(', '));
console.log('  route:   @' + team + ' team');
console.log('  repro:   ' + (hasRepro ? 'present' : 'MISSING, ask the reporter for exact steps'));
process.exit(1);
