#!/usr/bin/env node
// First-pass code review over a unified diff. Comments on the added lines only.
// Run:  node review.js <diff-file>     (in CI: gh pr diff <n> > pr.diff, then review.js pr.diff)
// It flags common, objective issues. The agent does the deeper read; this shows the shape of it.
const fs = require('fs');
const path = require('path');
const diff = fs.readFileSync(process.argv[2] || path.join(__dirname, 'sample-pr.diff'), 'utf8').split('\n');

const rules = [
  [/(api[_-]?key|secret|token|password)\s*[:=]\s*["'][^"']+["']|sk_live_/i, 'possible hardcoded secret, move it to a secret store'],
  [/console\.log\(/, 'debug log left in'],
  [/[^=!]==[^=]/, 'use === instead of =='],
  [/catch\s*\([^)]*\)\s*\{\s*\}/, 'empty catch swallows the error'],
  [/\b(TODO|FIXME)\b/, 'unfinished work marked but not done'],
];

let file = '?', line = 0, comments = [];
for (const raw of diff) {
  if (raw.startsWith('+++ b/')) { file = raw.slice(6); continue; }
  const hunk = raw.match(/^@@ -\d+(?:,\d+)? \+(\d+)/);
  if (hunk) { line = parseInt(hunk[1], 10); continue; }
  if (raw.startsWith('+') && !raw.startsWith('+++')) {
    const added = raw.slice(1);
    for (const [re, msg] of rules) if (re.test(added)) comments.push(`  ${file}:${line}  ${msg}`);
    line++;
  } else if (!raw.startsWith('-')) {
    line++;
  }
}

console.log('First-pass review (pack loop 8). Comments are advisory; a human approves and merges.');
if (!comments.length) { console.log('  no first-pass issues found'); process.exit(0); }
comments.forEach(c => console.log(c));
console.log(`\n${comments.length} comment(s) to post. The loop posts these on the PR and stops. It never approves or merges.`);
process.exit(1);
