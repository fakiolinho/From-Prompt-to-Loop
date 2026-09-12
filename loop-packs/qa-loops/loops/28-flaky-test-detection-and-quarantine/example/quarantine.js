// Quarantines a flaky test by name against a real tracking issue. The test keeps running and being
// measured, but stops blocking the build. Open the tracking issue first, then pass its URL here.
// This never deletes or weakens a test.
const fs = require('fs');
const path = require('path');
const [name, url] = process.argv.slice(2);
if (!name || !url) { console.error('usage: npm run quarantine -- <test-name> <tracking-issue-url>'); process.exit(1); }
if (!/^https?:\/\//i.test(url)) { console.error(`tracking issue must be an http(s) URL, got: ${url}`); process.exit(1); }
const qf = path.join(__dirname, 'quarantine.json');
const q = JSON.parse(fs.readFileSync(qf, 'utf8'));
if (q.quarantined.some(x => x.name === name)) { console.log(`${name} is already quarantined.`); process.exit(0); }
q.quarantined.push({ name, issue: url, quarantinedAt: new Date().toISOString().slice(0, 10) });
fs.writeFileSync(qf, JSON.stringify(q, null, 2) + '\n');
console.log(`quarantined ${name} against ${url}. Open a PR for review.`);
