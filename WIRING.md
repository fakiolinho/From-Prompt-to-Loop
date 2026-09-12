# Wiring reference

Every setting the loops read, generated from the checks themselves. Run
`python3 ci/build-wiring.py` after changing a check.

A loop whose setting is missing **exits 2 and tells you what it wanted**. It never guesses and
never wakes an agent. So you can install everything, fill in the ones you care about, and let
the rest sit quiet until you get to them.

## Where these go

`install.sh` writes a `loops.env` into your repo listing exactly the settings your chosen loops
need, each one commented out with an example. Fill in the lines you want and delete the rest.
Every chapter's runner loads that file before the check.

    ./install.sh ~/code/my-app 02          one loop
    ./install.sh ~/code/my-app engineering a whole chapter

Locally, the same file works by hand:

    set -a; . ./loops.env; set +a
    bash loops/02-dependency-upgrades/check.sh

The eleven loops not listed below read nothing. They work as soon as they are installed.


## Chapter 1 · Software engineering

| Loop | Setting | Example |
|---|---|---|
| **1** docs and examples sync | `LOOP_DOCS` | `npm run test:examples` |
| **2** dependency upgrades | `LOOP_VERIFY` | _no default_ |
| **3** codemod and framework migrations | `MIGRATION` | `react-18-to-19` |
|  | `LOOP_CODEMOD` | `npx jscodeshift -t ./codemods/foo.js src/` |
| **4** test backfill on changed code | `BASE_REF` | _no default_ |
| **7** release notes and changelog | `BASE_TAG` | _no default_ |
|  | `LOOP_MAX_COMMITS` | _no default_ |
| **8** first pass code review | `LOOP_PR_DIFF` | _no default_ |
|  | `LOOP_PR` | _no default_ |
| **9** issue triage and routing | `LOOP_ISSUE_FILE` | _no default_ |
|  | `LOOP_ISSUE` | _no default_ |

## Chapter 2 · Cloud and platform

These read no per loop settings. They need AWS credentials, or `DRY_RUN=1`
to run offline against the bundled mocks. See [SETUP.md](loop-packs/cloud-loops/SETUP.md).


## Chapter 3 · AI and ML engineering

| Loop | Setting | Example |
|---|---|---|
| **19** eval suite on prompt or model change | `LOOP_EVALS` | `node run-evals.js` |
| **20** rag knowledge base sync | `LOOP_RAG` | `node scripts/check-index-freshness.js` |
| **21** structured output conformance | `LOOP_SCHEMA` | `npx ajv validate -s schema.json -d ` |
| **22** model version upgrade testing | `LOOP_CANDIDATE` | `claude-opus-5` |
| **23** golden set growth from production failures | `LOOP_FAILURES` | `node scripts/recent-misses.js` |
| **24** prompt cost and routing optimisation | `LOOP_COST` | `node scripts/cost-report.js` |
| **25** safety and red team regression | `LOOP_REDTEAM` | `node run-evals.js --set redteam` |
| **26** data quality and drift monitoring | `LOOP_DRIFT` | `node scripts/drift-check.js` |

## Chapter 4 · QA and testing

| Loop | Setting | Example |
|---|---|---|
| **27** bug report to failing test | `LOOP_BUGS` | `gh issue list --label bug --json number,title` |
| **28** flaky test detection and quarantine | `LOOP_TEST` | `npm test` |
|  | `LOOP_RUNS` | _no default_ |
| **29** self healing ui tests | `LOOP_UI_TESTS` | `npx playwright test --reporter=json` |
| **30** test data and fixtures | `LOOP_FIXTURES` | `npx ajv validate -s schema.json -d \"fixtures/*.json\"` |
| **31** smoke tests on every deploy | `LOOP_SMOKE` | `./smoke.sh https://staging.example.com` |
| **32** cross browser and device matrix | `LOOP_MATRIX` | `npx playwright test --project=chromium --project=webkit` |
| **33** visual regression triage | `LOOP_VISUAL` | `npx playwright test --update-snapshots=none` |
| **34** e2e coverage from real user flows | `LOOP_JOURNEYS` | `node scripts/top-journeys.js` |
| **35** synthetic uptime and journey monitoring | `LOOP_SYNTHETIC` | `./journeys.sh https://example.com` |
