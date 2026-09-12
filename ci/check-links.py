#!/usr/bin/env python3
"""Every relative markdown link in the repo must point at something that exists."""
import re, os, glob

files = (glob.glob('*.md') + glob.glob('docs/*.md') + glob.glob('ci/*.md')
         + glob.glob('loop-packs/*/*.md') + glob.glob('loop-packs/*/loops/*/ORDERS.md'))

for f in sorted(files):
    base = os.path.dirname(f)
    for target in re.findall(r'\]\(([^)#\s]+?)(?:#[^)]*)?\)', open(f).read()):
        if target.startswith(('http://', 'https://', 'mailto:')):
            continue
        p = os.path.normpath(os.path.join(base, target))
        print(f"ok   {f} -> {target}" if os.path.exists(p)
              else f"FAIL {f} -> {target} does not exist")
