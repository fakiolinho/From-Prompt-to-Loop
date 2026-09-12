# Contributing

Contributions welcome, especially the kind that come from actually running a loop against a real
repository. Almost everything this project has learned came that way: that npm can call an older
version "latest", that `prettier --check .` walks into vendored code, that a suite with fewer
tests passes more easily. A bug report that starts *"I pointed loop 6 at my repo and it wanted
to reformat 10,000 files"* is worth more than a patch.

## Run the tests first

    ./ci/test-pack.sh engineering-loops    # one chapter
    ./ci/test-docs.sh                      # the book, the catalog, the site
    ./run-all-demos.sh                     # all four chapters against seeded data

No API key, no AWS account. Node 18 or newer, bash, and Python 3 for the `ci/` scripts. Two
Python packages, and that is the entire dependency list for the project:

    pip install markdown-it-py pyyaml

`markdown-it-py` renders the guide pages. `pyyaml` lets `check-workflows.py` read the four
chapter runners rather than trust them. GitHub's runners happen to ship pyyaml already, which is
exactly why it is pinned in the workflow: a dependency you only have by luck is one you will
lose without warning.

CI runs all of it on every push, one job per chapter, so a red square names the chapter.

## Three rules that are not negotiable

**1. The packs stay dependency free.** A chapter runs on Node 18 and bash. That is the promise
on the front door. Tooling in `ci/` may use Python; a loop may not.

**2. Never edit generated files.** `docs/*.html`, `docs/index.html` and `WIRING.md` are output.
Edit the markdown or the check, then run the generators:

    python3 ci/build-site.py       docs/index.html and the eight guide pages
    python3 ci/build-wiring.py     WIRING.md

On `main` a workflow does this for you. On a pull request it does not, because a bot cannot push
to your fork, so run them and commit the result.

**3. The field guide is the source of truth.** `ci/guide-catalog.tsv` is the published catalog
transcribed, and the tests fail if the repo drifts from it. If you have evidence the guide is
wrong, do not quietly change the catalog: change it, and add an entry to
[BOOK-CHANGES.md](BOOK-CHANGES.md) saying what you measured. That file is how a correction
reaches the next edition instead of dying in a diff.

## Adding or changing a loop

A check answers one question with three answers, and getting this wrong is the most common
mistake in the whole project:

    exit 0    no work. The run ends and costs nothing.
    exit 1    there is work. The agent wakes.
    exit 2    not wired to this repo. Fail loudly and say exactly what is missing.

Thirty three of thirty five loops once returned 1 where they meant 2, which on a weekly schedule
is a bill for agent runs that can only fail. If your check cannot tell, it says 2.

A new or changed loop needs all of:

- `check.sh` honouring those three codes, printing something a human can act on
- `ORDERS.md` with the four sections, an `**Owner:**` line, and a `**Needs:**` line if it reads
  a setting
- a `memory/NN-name.md` file
- a row in the chapter's `LOOPS.md` matching the catalog
- `python3 ci/build-wiring.py` rerun if you added a setting

Then the part that matters most: **run it against at least one repository you did not write.**
Say which, and what it found, in the pull request.

## Two habits the checks enforce

**Run the project's commands, never your own.** A project has already written down what it
lints and how far that reaches. A check that substitutes its own guess reaches further, and on a
real repository that meant flagging 10,434 files of vendored PHP where the project's own command
passed clean.

**A green command proves only what it covers.** Config read by filename, packages loaded at
runtime, and paths passed as strings are invisible to it. When a change touches one of those,
the loop flags rather than ships.

## House style

Plain words, and the checker is not subtle about it:

- no em dashes. Commas and full stops
- no hyphens in compound modifiers. "read only", "least privilege", "non zero"
- explain a term the first time it appears
- a sentence that needs a second read gets rewritten, not annotated

`python3 ci/check-style.py` enforces the mechanical half and also catches a file mangled into
binary by a bulk edit, which has happened.

## Pull requests

Say what you changed, what you ran it against, and what it found. If you changed a check, paste
its output from a real repository. If you changed the guide's catalog, link the BOOK-CHANGES
entry.

Security issues do not go here. See [SECURITY.md](SECURITY.md).
