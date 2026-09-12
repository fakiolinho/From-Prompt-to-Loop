*[Contents](../../../../README.md) · [Chapter 3: AI and ML engineering](../../LOOPS.md)*

# Loop 20. RAG knowledge base sync

**Trigger:** A source document changes
**Ships:** Ships on green. Opens a PR you can revert in one click. A regression blocks and opens an issue.
**Owner:** unassigned. Put a name here before this runs on a real repo. A loop nobody owns is a loop nobody maintains.
**The check:** `loops/20-rag-knowledge-base-sync/check.sh`. Run it from your project root. **0** nothing to do, **1** there is work, **2** not wired to this repo yet (it will say what it needs, and no agent runs).
**Needs:** `LOOP_RAG` (e.g. `node scripts/check-index-freshness.js`) in your `loops.env`. Without it the check exits 2 and this loop never runs. See [WIRING.md](../../../../WIRING.md).

## Run this loop

For the person setting this loop up. If you are the agent, this repo is already installed, so
skip to the next section.

**Have you already run `install.sh` to put this loop in your project?** Not sure? If
`loops/20-rag-knowledge-base-sync/check.sh` exists in your project, you have.

**Not yet.** From a clone of [From Prompt to Loop](https://github.com/fakiolinho/From-Prompt-to-Loop),
point it at your project folder. It copies this loop, the runner and a `loops.env`, and adds
the standing orders to your `CLAUDE.md` without replacing what is already there.

    ./install.sh ~/code/my-app 20

**Yes.** From your project root:

    ./run-loop.sh 20 --check    is there work? Never wakes an agent.
    ./run-loop.sh 20            if there is work, hand it to the agent.

The check answers **0** nothing to do, **1** there is work, or **2** not wired yet. A 2 prints
the setting it wants: add that line to `loops.env` and run it again. For more than one
setting, secrets, or a scheduled run in GitHub Actions, [WIRING.md](../../../../WIRING.md) has
every setting with an example.

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
