# Standing orders for the eval loop

_Codex reads this file. Claude reads CLAUDE.md. Identical, keep in sync._

## How to verify
- Run the evals: `npm test`
- A change is done only when accuracy is at or above `baseline.json`. Green, or it did not happen.

## What this loop owns, and what it must never touch
- Owns:  evals/cases.json and baseline.json
- Never: src/ (the system under test). And never lower the baseline to make a run pass.

## What to do on a run
- Run the evals. On an improvement, ratchet the bar: `npm run raise-baseline`, then open a PR for review (CI does this automatically on exit code 3). Never lower the baseline.
- If accuracy regressed, open an issue with the MISS lines and stop. Never ship a regression.
- When a real production failure comes in, add it as a case with the correct intent. The set compounds.

## When to stop and call a human
- A case whose correct intent is genuinely ambiguous. Flag it, do not guess the label.
- Any pressure to lower the baseline. The answer is no.

## Memory
- Read memory/evals.md at the start. Append one line per run.
