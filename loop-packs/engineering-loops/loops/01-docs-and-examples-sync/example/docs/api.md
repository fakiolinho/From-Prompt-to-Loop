# API reference

The docs loop keeps this file in sync with `src/index.js`. Do not hand edit drift in.

## createClient(options)

Creates a client.

- `options.key` (string, required) - your API key.
- `options.baseUrl` (string, optional) - defaults to `https://api.example.com`.

```js
const { createClient } = require('docs-loop');
const client = createClient({ key: 'sk-demo' });
```

## client.send(message)

Sends a message. `message` must be a string. Returns `{ id, text, status }`.

```js
const res = client.send('hello world');
console.log(res.id, res.status);
```
