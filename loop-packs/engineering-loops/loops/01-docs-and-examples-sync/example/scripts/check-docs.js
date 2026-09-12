// Checks that the documented API surface in docs/api.md covers the real code.
// Covers top-level exports AND the methods on objects that factory exports
// return, so client.send is inspected, not just the top-level createClient.
//
// note: still name-presence, not signature/param drift. It calls function
// exports with a dummy options bag and reads the methods off the result, so it
// only reaches factories that tolerate a dummy arg. Upgrade path: parse the AST
// and compare documented params to the real ones.
const fs = require('fs');
const path = require('path');

const sdk = require(path.join(__dirname, '..', 'src'));
const docs = fs.readFileSync(path.join(__dirname, '..', 'docs', 'api.md'), 'utf8');

const surface = new Set(Object.keys(sdk));

for (const name of Object.keys(sdk)) {
  if (typeof sdk[name] !== 'function') continue;
  let obj;
  try { obj = sdk[name]({ key: 'x', apiKey: 'x', token: 'x' }); } catch { continue; }
  if (!obj || typeof obj !== 'object') continue;
  const members = [...Object.keys(obj)];
  const proto = Object.getPrototypeOf(obj);
  if (proto && proto !== Object.prototype) {            // a class instance, walk its methods too
    members.push(...Object.getOwnPropertyNames(proto));
  }
  for (const m of members) {
    if (m !== 'constructor' && typeof obj[m] === 'function') surface.add(m);
  }
}

const missing = [...surface].filter(name => !docs.includes(name));

if (missing.length) {
  console.error('Docs drift: not documented in docs/api.md ->', missing.join(', '));
  process.exit(1);
}
console.log('Docs cover the full surface (' + surface.size + '):', [...surface].join(', '));
