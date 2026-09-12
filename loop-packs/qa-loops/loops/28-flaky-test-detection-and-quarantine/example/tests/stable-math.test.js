// A healthy test: deterministic, always passes.
module.exports = { name: 'stable-math', run() { if (2 + 2 !== 4) throw new Error('math is broken'); } };
