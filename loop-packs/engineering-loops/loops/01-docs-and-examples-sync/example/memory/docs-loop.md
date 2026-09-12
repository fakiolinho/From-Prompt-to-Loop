# Docs loop memory

Durable notes the loop keeps for itself across runs. Repo backed, so every change
is a reviewable commit. No secrets, ever.

## Log
- init: baseline. createClient(options) and client.send(message) documented and in sync.
- 2026-06-20: API renamed createClient option apiKey to key. Updated 01, 02 and docs/api.md to match.
- 2026-07-08: a doc can name every function correctly and still lie. The symbol check passed
  while example 02 was broken. The gate has to run the examples, not scan for names.
- 2026-08-14: breaking change to send(). Opened an issue and stopped, per the orders, rather
  than inventing a migration. The human shipped the rename the next morning.
