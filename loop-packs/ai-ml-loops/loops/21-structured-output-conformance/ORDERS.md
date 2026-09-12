*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 21. Structured output conformance

**Trigger:** A prompt or schema change
**Ships:** Ships on green. Opens a PR you can revert in one click. A regression blocks and opens an issue.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/21-structured-output-conformance/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  The output schema and the conformance tests
- Never: The prompt being tested

## What to do
- Validate a batch of real model outputs against the JSON schema.
- Block on any violation: a field missing, a wrong type, an unparseable response.
- Open a PR on loop/21-structured-output-conformance only when conformance holds.

## When to stop and call a human
- A schema change that would break downstream consumers. Flag it, do not loosen the schema to pass.
- Outputs that pass the schema but are obviously wrong. Note it, schema conformance is not correctness.

## Memory
- Read `memory/21-structured-output-conformance.md` at the start. Append one durable lesson at the end.

---

[← All ai and ml engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
