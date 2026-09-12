# ai-ml-loops-demo-app

A playground seeded with real work for the AI/ML loops, 20 through 26. It exists so you can watch
each loop find its problem, then fix it or hand it to an agent. Zero dependencies, pure Node, runs
offline immediately.

## Run the whole playground

    node loops.js all          # or: npm run check

Seven loops, each finds the problem seeded for it. Fix one, run again, watch it clear.

## What each loop finds

**Loop 20. RAG knowledge base sync** `npm run loop20`
`docs/` has three source docs; `index.json` is stale (one changed, one never indexed). The loop
reindexes and opens a PR. Try it: edit or add a doc, run it again.

**Loop 21. Structured output conformance** `npm run loop21`
`outputs.jsonl` has model outputs; two break `schema.json` (missing field, confidence out of range).
The loop adds validation or repair around the outputs, then re-checks. Try it: fix the two bad lines, run it again.

**Loop 22. Model version upgrade testing** `npm run loop22`
`models.json` says a new version is available. The loop runs the eval set against the candidate and
reports pass or regress before any switch. Try it: set `available` equal to `inUse`, run it again.

**Loop 23. Golden set growth** `npm run loop23`
`production-failures.jsonl` holds real misses; two are not in the eval set yet. The loop adds them
so the same miss can't return. Try it: copy a failure into `evals/cases.json`, run it again.

**Loop 24. Prompt cost and routing** `npm run loop24`
`traces.jsonl` has call logs; one is over budget, one used an expensive model for a greeting. The
loop proposes routing or prompt changes. Try it: lower the cost or model in `traces.jsonl`, run it again.

**Loop 25. Safety and red-team regression** `npm run loop25`
`redteam.json` is a set that must always be refused; the stand-in `guard.js` lets one through. The
loop blocks the change and opens an issue, it never weakens the set. The guard is deliberately
simple; the point is the set never regresses. Try it: add a pattern to `guard.js`, run it again.

**Loop 26. Data quality and drift** `npm run loop26`
`data/current.json` drifts from `data/baseline.json`: a null spike in `age` and a country shift. The
loop flags it before the data trains or evaluates anything. Try it: align `current.json`, run it again.

## Demo checks vs the real loops
These checks are simplified so the whole thing runs offline with no setup, the fastest way to build
intuition. In the pack the same loops run in CI against your real prompts, models, traces and data,
and the agent opens the PR while you review it. The classifier and guard here are stand-ins; swap in
your real system and the loop logic is unchanged.

## Then hand it to an agent
Once you have watched a loop find work, point the real loop at your project from its folder in the
pack and follow its ORDERS.md with Claude or Codex. That is the jump from reading the loops to
running them.
