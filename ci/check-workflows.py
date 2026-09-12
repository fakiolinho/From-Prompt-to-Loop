#!/usr/bin/env python3
"""The four pack workflows are the product. CI must read them, not just trust them."""
import glob, sys, yaml

fails = 0
paths = sorted(glob.glob('loop-packs/*/.github/workflows/loop.yml')) \
        + sorted(glob.glob('loop-packs/*/loops/*/example/.github/workflows/*.yml')) \
        + sorted(glob.glob('.github/workflows/*.yml'))

for p in paths:
    try:
        d = yaml.safe_load(open(p))
    except Exception as e:
        print(f"FAIL {p} is not valid YAML: {e}"); fails += 1; continue
    if not isinstance(d, dict) or 'jobs' not in d:
        print(f"FAIL {p} has no jobs"); fails += 1; continue
    print(f"ok   {p} parses, jobs: {', '.join(d['jobs'])}")

    if '/loops/' in p or p.startswith('.github/'):
        continue                                    # only the four pack runners below

    jobs = d['jobs']
    for name, why in [('run', 'wakes the agent'), ('verify', 'proves the work independently')]:
        if name in jobs:
            print(f"ok   {p} has a '{name}' job ({why})")
        else:
            print(f"FAIL {p} has no '{name}' job ({why})"); fails += 1

    run = jobs.get('run', {})
    if run.get('outputs', {}).get('work'):
        print(f"ok   {p} run publishes the check's exit code")
    else:
        print(f"FAIL {p} run does not publish the check's exit code, so verify cannot gate on it")
        fails += 1

    # the agent must never wake on anything but exit 1
    agent_steps = [s for s in run.get('steps', []) if 'claude-code' in str(s.get('run', ''))
                   or 'openai/codex' in str(s.get('run', ''))]
    if not agent_steps:
        print(f"FAIL {p} has no agent step"); fails += 1
    for s in agent_steps:
        if "steps.check.outputs.code == '1'" in str(s.get('if', '')):
            print(f"ok   {p} agent step '{s.get('name')}' wakes only on exit 1")
        else:
            print(f"FAIL {p} agent step '{s.get('name')}' is not gated on exit code 1")
            fails += 1

    for key, why in [('timeout-minutes', 'a runaway run must die on its own')]:
        if run.get(key):
            print(f"ok   {p} run has {key} ({why})")
        else:
            print(f"FAIL {p} run has no {key}: {why}"); fails += 1

print("ok   all workflows sound" if not fails else f"FAIL {fails} workflow problem(s)")
sys.exit(1 if fails else 0)
