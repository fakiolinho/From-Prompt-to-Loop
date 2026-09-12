# The repo's own tests

These prove the packs still work. No API key, no AWS account, no agent runs.

    ./ci/test-pack.sh engineering-loops    # one chapter
    ./ci/test-pack.sh cloud-loops
    ./ci/test-pack.sh ai-ml-loops
    ./ci/test-pack.sh qa-loops
    ./ci/test-docs.sh                      # the book and the catalog
    python3 ci/check-links.py              # just the links
    python3 ci/check-style.py              # house style
    python3 ci/check-workflows.py          # the four pack runners

## What these need

    pip install markdown-it-py pyyaml

Nothing else. The loops themselves stay on Node 18 and bash; Python is for the tooling here.

## The generators

Two files in `docs/` and one at the root are generated. Run these after changing anything they
read, and commit the result. `ci/test-docs.sh` fails if what is committed has gone stale.

    python3 ci/build-site.py       docs/index.html and the eight guide pages
    python3 ci/build-wiring.py     WIRING.md, from the settings the checks actually read

`build-site.py` renders each `docs/*.md` to HTML and rewrites the links for the web. The
markdown stays the single source of truth, so never edit `docs/*.html` by hand.

**On main you do not have to run them.** `.github/workflows/build-site.yml` renders and commits
the result on every push that touches the markdown, the diagrams, the catalog or a check. Edit
the markdown, push, and the page GitHub Pages serves follows a moment later.

On a pull request it is not automatic, because a bot cannot push to your fork's branch. There
the tests ask you to run both generators and commit, so a reviewer reads the real page. The landing
page is the exception: its content lives in the generator's template, which is why a test
checks it still tells the same story as `README.md`.

`.github/workflows/tests.yml` runs all of them on every push, one job per chapter, so a red
square tells you which chapter broke.

## What `test-pack.sh` proves

1. Every `check.sh` is valid bash.
2. Every `check.sh` honours the contract: **0** no work, **1** work, **2** not wired here.
   Checks run from a real project root (the pack's `demo-app`), the way a person runs them.
3. Every `check.sh` prints something. A silent check is one nobody can read.
4. Every loop has its `ORDERS.md` and its `memory/` file.
5. The pack's `demo-app` still finds the work it was seeded with.
6. Every runnable example still passes its own tests. Two are expected to go red on purpose:
   loop 28 must catch its planted flaky test, and loop 19 exits 3 when accuracy is above
   baseline and the baseline wants ratcheting.

## What `test-docs.sh` proves

`ci/guide-catalog.tsv` is the catalog transcribed from the field guide (pages 22-25). It is the
source of truth. The test checks the repo against it:

**The guide is a book, so it is tested like one:**

- all eight pages of `docs/` exist, and the contents page in `README.md` lists every one
- no page is a dead end: every guide page and every chapter page links back to the contents
- every relative markdown link in the repo resolves (`ci/check-links.py`), so a renamed page
  cannot quietly orphan another
- house style holds (`ci/check-style.py`): no em dashes, no unclosed code spans, and no file
  mangled into binary by a bulk edit
- the four pack runners parse and are wired correctly (`ci/check-workflows.py`): each has a
  `run` job and a `verify` job, the agent step wakes only on exit code 1, and the job carries a
  timeout. These files are the product, so CI reads them rather than trusting them
- every loop names an owner, every chapter ships a PR template, and every `.gitignore` blocks
  `.env`
- the field guide PDF is where the docs say it is

**And the catalog still matches the guide:**

- all 35 loops exist, in the right chapter, with nothing extra
- each loop's **Ships on green** / **Flags, you decide** tag matches the guide, in `ORDERS.md`
  and in the chapter's `LOOPS.md`
- the guide's three starred loops (2, 6, 7) are marked as such
- every `ORDERS.md` has the four sections an agent reads
- no placeholder words, no links to folders that were never shipped
- the loop counts the docs claim are the counts on disk

**If the guide changes**, edit `ci/guide-catalog.tsv` first, then run `./ci/test-docs.sh` and fix
whatever it reports.
