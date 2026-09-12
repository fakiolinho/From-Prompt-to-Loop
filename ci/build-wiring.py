#!/usr/bin/env python3
"""Generate WIRING.md: every setting every loop reads, from the checks themselves."""
import glob, os, re, sys

CH = {"engineering-loops": (1, "Software engineering"), "cloud-loops": (2, "Cloud and platform"),
      "ai-ml-loops": (3, "AI and ML engineering"), "qa-loops": (4, "QA and testing")}
VAR = re.compile(r'\$\{(LOOP_[A-Z_]+|MIGRATION|BASE_REF|BASE_TAG)(?::-[^}]*)?\}')

rows = []
for f in sorted(glob.glob("loop-packs/*/loops/*/check.sh")):
    pack, loop = f.split("/")[1], f.split("/")[3]
    src = open(f).read()
    seen, out = set(), []
    for m in VAR.finditer(src):
        v = m.group(1)
        if v in seen: continue
        seen.add(v)
        ex = re.search(rf"{v}='([^']*)'", src)
        out.append((v, ex.group(1) if ex else ""))
    if out: rows.append((pack, loop, out))

body = ["""# Wiring reference

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
"""]

for pack in ["engineering-loops", "cloud-loops", "ai-ml-loops", "qa-loops"]:
    mine = [r for r in rows if r[0] == pack]
    n, title = CH[pack]
    body.append(f"\n## Chapter {n} · {title}\n")
    if pack == "cloud-loops":
        body.append("These read no per loop settings. They need AWS credentials, or `DRY_RUN=1`\n"
                    "to run offline against the bundled mocks. See "
                    "[SETUP.md](loop-packs/cloud-loops/SETUP.md).\n")
        if not mine: continue
    body.append("| Loop | Setting | Example |")
    body.append("|---|---|---|")
    for _, loop, vars_ in mine:
        num, name = loop[:2], loop[3:].replace("-", " ")
        for i, (v, ex) in enumerate(vars_):
            label = f"**{int(num)}** {name}" if i == 0 else ""
            body.append(f"| {label} | `{v}` | {'`' + ex + '`' if ex else '_no default_'} |")

open("WIRING.md", "w").write("\n".join(body) + "\n")
print(f"ok   WIRING.md written, {len(rows)} loops need settings")
