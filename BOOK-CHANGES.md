# Changes to apply to the field guide

The repo and the published PDF are meant to agree. `ci/guide-catalog.tsv` is the guide's
catalog transcribed, and `ci/test-docs.sh` fails if the repo drifts from it. When real
evidence forces the repo to change, the change lands here so the next revision of
*From Prompt to Loop* can catch up.

Each entry says what to change, where, and what the evidence was.

---

## 1. Chapter 1 is Software engineering, not General engineering

**Where:** page 3 (contents), page 22 (the catalog heading above loop 1).

**Change:** `General engineering` becomes `Software engineering`.

**Why:** editorial. Applied across the repo on 2026-09-12.

---

## 2. Loop 5 is Flags, you decide, not Ships on green

**Where:** page 23, loop 5, the tag at the end of the entry.

**Change:**

> 5. Dead code and unused dependency removal. A loop finds unreferenced code and packages,
> strips them, and runs the full build. ~~Ships on green.~~ **Flags, you decide.**

Suggested replacement for the whole entry, since the reasoning changes too:

> **5. Dead code and unused dependency removal.** A loop finds unreferenced code and packages
> and opens an issue with the candidates and the evidence for each. A smaller attack surface,
> faster builds and a lighter bill, but a human presses delete. Static analysis cannot see a
> config file loaded by convention, a fixture passed as a path, or a test file reached by a
> glob, and a green build does not prove a cut was safe. **Flags, you decide.**

**Why:** tested against two real repositories on 2026-09-12.

- On a Next.js site, knip flagged 8 candidates. Two would have broken production:
  `open-next.config.ts`, which the Cloudflare deploy reads by filename and nothing imports,
  and `sharp`, which Next loads at runtime for image optimisation. `next build` stayed green
  for both.
- On a larger app, knip flagged 34 files, 181 exports and 4 devDependencies. Among them 22
  test fixtures passed to scripts as path arguments, three test files, and the helper all
  three import. The cause was one unseen entry point: the tests run from a glob inside an npm
  script, so everything they reach looked unreachable.
- The decisive part. Loop 5's safety net was "the build and full test suite confirm it".
  Running the suite as it would look after the proposed cut: **495 tests before, 446 after,
  zero failures, exit green.** Forty nine tests would silently stop running and the gate would
  report success. Deleting tests makes a test suite easier to pass, so the verification is not
  weak here, it is defeated by the action the loop performs.

This is the five question test answering no to question two, "can it check its own work,
cheaply and honestly?" A loop that fails question two is not a loop.

**Consider also:** page 21 uses "keeping your code free of known security holes" to show that
the line between loop and not-a-loop can run through a single task. Loop 5 is a second, sharper
example of the same idea, and one where the evidence is measured rather than argued.

---

## 3. A check has three answers, not two

**Where:** page 9, the anatomy diagram, box 2. Also the check description on page 19,
question 2 of the five question test.

**Change:** the diagram shows the check branching two ways, "Nothing to do" and "There is
work". Add the third branch:

> **Not wired.** The check cannot see what it needs in this repo. The run fails loudly and the
> agent never wakes. A loop pointed at a repo it cannot read is not idle, it is expensive.

Suggested wording for box 2:

>     Nothing to do      There is work        Not wired
>     Exit. A green      Wake the agent,      Fail loudly. Never wake an agent
>     night wakes        under standing       to work on a repo the check
>     nobody.            orders.              cannot actually read.

**Why:** measured on two real repositories on 2026-09-12. **Thirty three of all thirty five
loops** returned "there is work" on repos they were not wired to, because "is there work" only
had two answers. On a weekly schedule that is thirty three agent runs a week, each capped at two
dollars, all of them finding nothing to do, on every repo that adopts the pack.

The cloud chapter was the sharpest case. All nine printed "cannot read ECR", "cannot read
CloudWatch", "cannot read ACM" and then returned 1. "I cannot reach your account" was being
reported as "there is work here", which wakes an agent to investigate infrastructure it has no
credentials for. Nine runs a week that can only fail.

The loops now return 2 for "not wired" and say what to wire. The idea generalises past this
repo: any check with only two answers will answer "there is work" when it is really answering
"I cannot tell".

---

## 4. Minor caveats worth a sentence

**Loop 6, page 22.** "A loop runs the linter, formatter, and type checker on changed files."
Add: only the ones that project actually uses. Running a formatter a project never adopted
flags every file it owns. On a real site `prettier --check .` reported 364 files in a repo with
no prettier dependency, which is not a lint fix, it is an unwanted rewrite of the whole
codebase. The same loop must use the project's pinned tool versions: fetching the newest
major instead got eslint 10 on a repo pinned to eslint 9, which simply crashed.

**Loop 2, page 22.** "your only risk is integration and the tests catch that" assumes tests
exist. Add: and it is worth exactly as much as that command is. A repo with no test suite gets
no safety from this loop, which is why the check now refuses to run without one.
