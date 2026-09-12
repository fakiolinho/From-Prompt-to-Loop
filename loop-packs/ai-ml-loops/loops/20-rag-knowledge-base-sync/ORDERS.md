*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 20. RAG knowledge base sync

**Trigger:** A source document changes
**Ships:** Ships on green. Opens a PR you can revert in one click. A regression blocks and opens an issue.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/20-rag-knowledge-base-sync/check.sh`. Exits 0 when there is nothing to do, non zero when there is work.

## Owns, and never touches
- Owns:  The index and embeddings
- Never: The source documents themselves

## What to do
- When a source changes, embed and index that source again. Nothing else.
- Once it is indexed, run the retrieval smoke queries and confirm they still return the right passages.
- Open a PR on loop/20-rag-knowledge-base-sync. Stale retrieval is silent rot until someone gets a wrong answer.

## When to stop and call a human
- A source whose new content contradicts an existing one. Flag the conflict, do not silently pick a winner.
- Retrieval quality that drops once it is indexed. Stop and open an issue.

## Memory
- Read `memory/20-rag-knowledge-base-sync.md` at the start. Append one durable lesson at the end.

---

[← All ai and ml engineering loops](../../LOOPS.md) · [Contents](../../../../README.md) · [What a loop is](../../../../docs/01-what-is-a-loop.md)
