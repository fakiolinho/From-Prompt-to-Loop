// A FLAKY test: it depends on a simulated unreliable service, so it passes only sometimes.
// This is exactly the kind of test the loop must catch and quarantine, never delete.
module.exports = {
  name: 'order-lookup',
  run() {
    // note: simulated flakiness. In a real suite this is a race or a network timeout.
    if (Math.random() < 0.5) throw new Error('timeout talking to order service');
  },
};
