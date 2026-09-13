# Changes to apply to the field guide

The repo and the published PDF are meant to agree. `ci/guide-catalog.tsv` is the guide's
catalog transcribed, and `ci/test-docs.sh` fails if the repo drifts from it. When real
evidence forces the repo to change, the change lands here so the next revision of
*From Prompt to Loop* can catch up.

Each entry says what to change, where, what the evidence was, and whether a revision has applied
it. [CHANGELOG.md](CHANGELOG.md) lists what each revision of the PDF changed.

**Second revision, September 2026:** applies entries 1 to 7, except pages 19 and 20 under
entry 3.

**Open for the next revision:** entry 3 (pages 19 and 20), and entries 8 to 15, found on
2026-09-13 by checking the second revision page by page against the repo.

---

## 1. Chapter 1 is Software engineering, not General engineering

**Status:** applied in the second revision.

**Where:** page 3 (contents), page 22 (the catalog heading above loop 1).

**Change:** `General engineering` becomes `Software engineering`.

**Why:** editorial. Applied across the repo on 2026-09-12.

---

## 2. Loop 5 is Flags, you decide, not Ships on green

**Status:** applied in the second revision, with the suggested replacement entry.

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

**Status:** applied on page 9 in the second revision. **Still open:** pages 19 and 20, question 2
of the five question test, still describe the check as pass or fail.

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

**Status:** applied in the second revision. Loop 2 in full. Loop 6 carries it through entry 5's
wording, and the note about using the project's pinned tool versions did not make the page.

**Loop 6, page 22.** "A loop runs the linter, formatter, and type checker on changed files."
Add: only the ones that project actually uses. Running a formatter a project never adopted
flags every file it owns. On a real site `prettier --check .` reported 364 files in a repo with
no prettier dependency, which is not a lint fix, it is an unwanted rewrite of the whole
codebase. The same loop must use the project's pinned tool versions: fetching the newest
major instead got eslint 10 on a repo pinned to eslint 9, which simply crashed.

**Loop 2, page 22.** "your only risk is integration and the tests catch that" assumes tests
exist. Add: and it is worth exactly as much as that command is. A repo with no test suite gets
no safety from this loop, which is why the check now refuses to run without one.

---

## 5. A loop runs the project's commands. It never invents its own.

**Status:** applied in the second revision, on page 22 (loop 6) and page 9 (box 3).

**Where:** loop 6, page 22. Also worth a line in the anatomy, page 9, box 3, and in the
starter pack on page 27 where CLAUDE.md names one verification command.

**Change:** add the principle, and make loop 6's entry carry it:

> **6. Lint, format, and type fixes.** A loop runs the lint, format and type commands **the
> project already defines** and applies the mechanical fixes. Not commands the loop invents.
> A project has already written down what it checks and how far it reaches; a loop that
> guesses instead will reach further. Pure busywork, fully checkable, trivially reversible.
> Ships on green.

**Why:** measured on four real repositories on 2026-09-12.

A Laravel plus Vite service scopes its own tooling deliberately:

    lint        eslint "resources/**/*.{tsx,jsx,js,ts}"
    prettify    prettier --check "resources/**/*.{tsx,jsx,js}"
                prettier --check "{app,config,database,resources,routes,tests}/**/*.php"

All three of the project's commands pass. The loop's invented `prettier --check .` on the
same repo, at the same moment, flagged **10,762 files**, of which **10,434 were in vendor/**,
third party PHP the project does not own. That loop would have opened a pull request
reformatting somebody else's dependencies.

A second repo showed the milder version: 91 files flagged against a default style it never
adopted, while its own lint script passed. A third pulled eslint 10 from the registry to lint
a project pinned to eslint 9, and crashed.

The principle generalises past linting, which is why it belongs in the anatomy too. The
project's scripts are where a team has written down its intent. A loop that substitutes its
own guess is not automating the team's standard, it is imposing a different one at scale.

---

## 6. Loop 7 needs a release tag, not just any tag

**Status:** applied in the second revision.

**Where:** loop 7, page 22.

**Change:** add one sentence to the entry:

> On every tag a loop drafts the notes from merged PRs, checks the links, and opens the
> release. **It measures from the last release, so it needs a version shaped tag; the nearest
> tag is not always a release.**

**Why:** a real service had exactly one tag, named `patch`. `git describe` returns it happily,
so the loop measured from there and reported **710 commits to add to the changelog**. A repo
with no tags at all was worse: it counted every commit ever made, 453 of them, and called them
release notes.

The loop now takes the newest version shaped tag, and refuses when the range is implausibly
large, because a release note covering hundreds of commits means the baseline is wrong rather
than that there is a lot to write.

---

## 7. Say plainly that a local run needs no API key

**Status:** applied in the second revision, on page 35.

**Where:** page 2, "what you are holding", or the prerequisites implied on page 26. Also page 35,
the billing box, which currently only carries the warning half.

**Change:** page 35 says, correctly, that interactive work and a loop calling `claude -p` from
CI are metered differently, and that you should not assume your subscription covers a fleet.
That is the right warning and it should stay. What is missing is the other half, and it is the
half that gets somebody started:

> Running a loop on your own machine uses whatever login your agent already has. If you are
> signed in to Claude Code, a subscription included, there is nothing to buy to try this. The
> key is for the unattended runs: a CI runner has no login, so it reads one from your secrets,
> and that is the usage metered per token.

**Why:** the repo had the same gap and it was worse there. The README never mentioned cost or
keys at all, and the only place the word "subscription" appeared was the warning that it might
not cover a fleet. A reader could reasonably conclude they had to buy API credits before they
could try anything, when in fact the demos, every check, and a local `run-loop.sh` all run on
what they already have.

Verified on 2026-09-12 with no `ANTHROPIC_API_KEY` in the environment: `claude -p` authenticated
on the existing login and ran.

The fix in the repo is a short table on the front door, showing what each of the three surfaces
needs and what it costs, plus the caps. The guide has the cost chapter to do this properly; it
just needs the "nothing to buy to start" sentence somewhere a beginner meets early.

---

## 8. Loop 2 runs on a build script too

**Status:** open.

**Where:** page 22, loop 2.

**Change:** "A repo with no tests gets no safety here, which is why the check refuses to run
without one" becomes:

> A repo with nothing that proves a bump is safe, no tests and no build, gets no safety here,
> which is why the check refuses to run on one.

**Why:** the check takes the project's `test` script, then its `build` script, then
`LOOP_VERIFY`, and exits 2 only when there is none of them. On 2026-09-13 a Next.js site with no
test suite ran loop 2 on `npm run build` and bumped five packages.

---

## 9. The starter pack workflow gives the check two answers

**Status:** open.

**Where:** page 28, `.github/workflows/docs-loop.yml`.

**Change:** the check step has `continue-on-error: true` and the agent step runs on
`if: steps.check.outcome == 'failure'`. Any failure wakes the agent, including a repo with no
`check-docs` script at all. That is entry 3's bug, printed in the one workflow a reader copies.
Suggested replacement for the check and the agent condition:

    - id: check
      run: |
        if ! node -e 'process.exit((require("./package.json").scripts||{})["check-docs"]?0:1)'; then
          echo "::error::no check-docs script. Not wired, no agent."
          exit 2
        fi
        if npm run check-docs; then echo "answer=0" >> "$GITHUB_OUTPUT"
        else echo "answer=1" >> "$GITHUB_OUTPUT"; fi
    - name: Sync only on drift
      if: steps.check.outputs.answer == '1'

**Why:** page 9 now says a check has three answers, and the workflow on page 28 still has two.
The repo's own copy of this example had the same bug, and was fixed on 2026-09-13.

---

## 10. The retry ceiling is two identical failures, not three

**Status:** open.

**Where:** page 29, "Cap it at three", and page 37, "three tries then stop and flag".

**Change:** "Stop after two runs that fail the same way, and flag it. Never try a third."

**Why:** every chapter's standing orders in the repo, and both agent prompts in every runner,
say two: "The third identical failure is not the one that works, and every turn you spend on it
is money out of someone's budget." Either number can be argued, but the book and the orders a
reader installs should say the same one.

---

## 11. One runner per group of loops, not one workflow per loop

**Status:** open.

**Where:** page 31, "One workflow file per loop".

**Change:** "One workflow per group of loops, and each run names its loop." Or keep one file per
loop, and say the repo groups them.

**Why:** the repo ships one `loop.yml` per chapter, with the loop as an input to the run. Nine
files per chapter would repeat the same fence, caps and verify job nine times, and drift.

---

## 12. The Codex line needs a writable sandbox

**Status:** open.

**Where:** page 30, "the one line that changes in the workflow".

**Change:** `npx @openai/codex exec "..."` becomes
`npx @openai/codex exec --sandbox workspace-write "..."`.

**Why:** a loop has to edit files. Every Codex call in the repo passes this flag, and it plays
the part `--allowedTools` plays for Claude: the fence, stated where it is enforced.

---

## 13. The repo has shipped

**Status:** open.

**Where:** page 39, "What happens next".

**Change:** "The runnable repo ... is being finished now. When it lands I will send it to you"
becomes a pointer to it: `github.com/fakiolinho/From-Prompt-to-Loop`. Keep the list link for
people who want the next revision, but the reader needs the repo.

**Why:** the repo released 1.0.0 in September 2026. See [CHANGELOG.md](CHANGELOG.md).

---

## 14. Run it on your own machine before you schedule it

**Status:** open.

**Where:** page 29, the starter pack's "Run it" steps.

**Change:** add a step before scheduling:

> Try it where you can watch it. `./install.sh ~/code/my-app 02` puts one loop in your repo,
> `./run-loop.sh 02 --check` asks whether there is work, and `./run-loop.sh 02` runs it once on
> your own login. Read the diff. Then schedule it.

**Why:** page 35 now says a local run costs nothing extra, and page 29 still jumps from dropping
in CLAUDE.md straight to a schedule. The first real run of loop 2 was local, and what it found
(entries 8 and 15) would otherwise have repeated on every scheduled run.

---

## 15. An upgrade that can never land needs a way to park it

**Status:** open.

**Where:** page 22, loop 2.

**Change:** add one sentence: "If an upgrade cannot land, a peer dependency pin say, park it
by name, or the loop wakes an agent every run to fail at the same thing."

**Why:** on 2026-09-13, `@opennextjs/cloudflare` 1.20.6 needed `next` 16.3.3 or newer on a site
pinned to 16.2.10. The agent was right to stop, but the check kept counting the upgrade, so
every scheduled run would have spent up to two dollars on the same failure. The repo now reads
`LOOP_HOLD`.
