// A tiny pretend SDK. Its docs and examples must stay in sync with this file.
// The docs loop's whole job is to keep /docs and /examples matching this API.

function createClient(options = {}) {
  if (!options.key) {
    throw new Error('createClient: key is required');
  }
  return {
    key: options.key,
    baseUrl: options.baseUrl || 'https://api.example.com',
    send(message) {
      if (typeof message !== 'string') {
        throw new Error('send: message must be a string');
      }
      // note: pretend network call, no real I/O so examples run offline in CI.
      return { id: 'msg_' + Math.random().toString(36).slice(2, 8), text: message, status: 'sent' };
    },
  };
}

module.exports = { createClient };
