#!/usr/bin/env python3
"""House style, enforced. Plain words, no stray punctuation, no mangled files.

Rules:
  1. No NUL bytes or control junk. A text file that reads as binary is a corrupted file.
  2. No em dashes in prose. This house writes with commas and full stops.
  3. Backticks come in pairs on a line. An odd count means a code span lost its partner.
"""
import os, sys

SKIP_DIRS = {'.git', 'node_modules', '.idea'}
EXTS = ('.md', '.sh', '.js', '.yml', '.json', '.tsv', '.py')
# the demo apps print to a terminal; their source is checked, their output is their own
fails = 0

def walk():
    for root, dirs, files in os.walk('.'):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for fn in files:
            if fn.endswith(EXTS):
                yield os.path.join(root, fn)

for p in sorted(walk()):
    raw = open(p, 'rb').read()
    if b'\x00' in raw:
        print(f"FAIL {p} contains NUL bytes. Something mangled this file."); fails += 1
        continue
    try:
        text = raw.decode('utf-8')
    except UnicodeDecodeError:
        print(f"FAIL {p} is not valid UTF-8"); fails += 1
        continue

    if p.endswith('.md'):
        for i, line in enumerate(text.split('\n'), 1):
            if '—' in line:
                print(f"FAIL {p}:{i} uses an em dash. Use a comma or a full stop."); fails += 1
            if line.count('`') % 2 and '```' not in line:
                print(f"FAIL {p}:{i} has an unclosed code span"); fails += 1

print(f"ok   {len(list(walk()))} files clean" if not fails else f"FAIL {fails} style problem(s)")
sys.exit(1 if fails else 0)
