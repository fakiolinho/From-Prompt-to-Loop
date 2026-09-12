// A healthy test: deterministic, always passes.
module.exports = { name: 'stable-string', run() { if ('ab'.length !== 2) throw new Error('strings are broken'); } };
