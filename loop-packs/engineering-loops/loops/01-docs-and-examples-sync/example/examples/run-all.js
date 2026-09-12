// Runs every numbered example as the loop's self-check.
// Green here is the ONLY thing that lets the docs loop ship.
const fs = require('fs');
const path = require('path');

const dir = __dirname;
const files = fs.readdirSync(dir).filter(f => /^\d+.*\.js$/.test(f)).sort();

let failed = 0;
for (const f of files) {
  try {
    delete require.cache[require.resolve(path.join(dir, f))];
    require(path.join(dir, f));
    console.log('  PASS', f);
  } catch (e) {
    failed++;
    console.error('  FAIL', f, '->', e.message);
  }
}

if (failed) {
  console.error('\n' + failed + ' example(s) failed. The docs loop will NOT ship.');
  process.exit(1);
}
console.log('\nAll ' + files.length + ' examples ran. Green. Safe to ship.');
