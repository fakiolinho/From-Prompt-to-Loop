# Memory: eval loop

What this loop has learned about this eval set. One line per run, newest last.
Repo backed, so every entry is a reviewable commit. No secrets, ever.

## Log
- init: baseline 0.90 on 20 cases. Intent classifier, deterministic, no network.
- 2026-04-11: "speak to a representative" was classified support, not help. A real miss from
  production, added as a case rather than argued about. Set grew to 20.
- 2026-05-02: accuracy hit 1.00 and stayed there for four runs. Ratcheted the baseline to 0.95
  rather than 1.00, so one genuinely ambiguous utterance cannot turn a good change red.
- 2026-05-19: tried raising to 1.00 after a clean fortnight. Reverted the same day: "cancel my
  card" is legitimately either cancel or help, and a bar of 1.00 makes that one case the gate
  on every future change.
- 2026-06-03: a regression turned out to be a bad label, not a bad model. Check the case before
  you blame the classifier. Two runs lost to this.
