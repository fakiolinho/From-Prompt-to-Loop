#!/usr/bin/env python3
"""Generate docs/index.html, the page GitHub Pages serves.

One page. Its job is to get somebody running the demos before they start reading
the repo. Everything on it is generated from the repo's own data, so it cannot
drift: the catalog comes from ci/guide-catalog.tsv, the rows from each chapter's
LOOPS.md, and the demo output from an actual run recorded in ci/demo-output.txt.

Run it, commit the result. ci/test-docs.sh fails if the committed page is stale.
"""
import html, os, re, sys

REPO = "https://github.com/fakiolinho/From-Prompt-to-Loop"
CHAPTERS = {
    "engineering-loops": (1, "General engineering", "1-9"),
    "cloud-loops":       (2, "Cloud and platform", "10-18"),
    "ai-ml-loops":       (3, "AI and ML engineering", "19-26"),
    "qa-loops":          (4, "QA and testing", "27-35"),
}

def catalog():
    rows = []
    for line in open("ci/guide-catalog.tsv"):
        if line.startswith("#") or not line.strip():
            continue
        num, pack, tag, star, name = line.rstrip("\n").split("\t")
        rows.append(dict(num=num, pack=pack, tag=tag, star=star == "yes", name=name))
    return rows

def folders():
    out = {}
    for pack in CHAPTERS:
        for d in sorted(os.listdir(f"loop-packs/{pack}/loops")):
            out[(pack, d[:2])] = d
    return out

def detail(pack, num):
    """The 'check looks for' and 'runnable now' cells, straight from LOOPS.md."""
    n = int(num)
    for line in open(f"loop-packs/{pack}/LOOPS.md"):
        m = re.match(rf"^\|\s*{n}\s*\|", line)
        if not m:
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        looks, runs = cells[-2], cells[-1]
        clean = lambda t: re.sub(r"\*\*|`|\[|\]\([^)]*\)", "", t).strip()
        return clean(looks), clean(runs)
    return "", ""

def main():
    rows, fold = catalog(), folders()
    demo = open("ci/demo-output.txt").read() if os.path.exists("ci/demo-output.txt") else ""

    cards = []
    for r in rows:
        ch, title, _ = CHAPTERS[r["pack"]]
        d = fold[(r["pack"], r["num"])]
        looks, runs = detail(r["pack"], r["num"])
        ships = r["tag"] == "ships"
        ready = runs.lower().startswith("yes")
        cards.append(
            f'<a class="loop" href="{REPO}/blob/main/loop-packs/{r["pack"]}/loops/{d}/ORDERS.md"'
            f' data-ch="{ch}" data-tag="{r["tag"]}" data-ready="{"1" if ready else "0"}"'
            f' data-q="{html.escape((r["name"] + " " + looks).lower(), quote=True)}">'
            f'<span class="num">{int(r["num"])}</span>'
            f'<span class="body"><span class="name">{html.escape(r["name"])}'
            + ('<span class="star" title="one of the guide\'s three easiest first builds">★</span>' if r["star"] else "")
            + (f'<span class="ready" title="ships working code you can run right now">runnable</span>' if ready else "")
            + f'</span><span class="looks">{html.escape(looks)}</span></span>'
            f'<span class="tag {"ships" if ships else "flags"}">'
            f'{"Ships on green" if ships else "Flags, you decide"}</span></a>'
        )

    chapter_pills = "".join(
        f'<button class="pill" data-f="ch" data-v="{n}">Ch {n} · {t}</button>'
        for _, (n, t, _) in sorted(CHAPTERS.items(), key=lambda kv: kv[1][0])
    )

    page = TEMPLATE.format(
        repo=REPO,
        cards="\n".join(cards),
        chapter_pills=chapter_pills,
        demo=html.escape(demo.strip()),
        total=len(rows),
    )
    os.makedirs("docs", exist_ok=True)
    open("docs/index.html", "w").write(page)
    open("docs/.nojekyll", "w").write("")
    print(f"ok   docs/index.html written, {len(rows)} loops")

TEMPLATE = r"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>From Prompt to Loop &middot; 35 runnable loops</title>
<meta name="description" content="Thirty five loops that keep a product alive after it ships. Runnable on Claude Code or Codex. One command to see them all working.">
<meta property="og:title" content="From Prompt to Loop &middot; 35 runnable loops">
<meta property="og:description" content="Thirty five loops that keep a product alive after it ships. One command to watch them find real work.">
<meta property="og:type" content="website">
<style>
  :root {{
    --bg:#0b0e14; --panel:#131823; --line:#232b3b; --ink:#e6e9ef; --dim:#93a0b5;
    --amber:#f59e0b; --green:#10b981; --violet:#8b5cf6; --blue:#3b82f6;
    --mono: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  }}
  * {{ box-sizing:border-box; }}
  body {{ margin:0; background:var(--bg); color:var(--ink);
    font:16px/1.6 ui-sans-serif,-apple-system,"Segoe UI",Roboto,sans-serif; }}
  .wrap {{ max-width:1000px; margin:0 auto; padding:0 20px; }}
  a {{ color:inherit; }}

  header {{ padding:64px 0 40px; border-bottom:1px solid var(--line); }}
  h1 {{ font-size:clamp(30px,5vw,46px); line-height:1.12; margin:0 0 14px; letter-spacing:-.02em; }}
  h1 small {{ display:block; font-size:15px; font-weight:600; color:var(--amber);
    letter-spacing:.12em; text-transform:uppercase; margin-bottom:14px; }}
  .lede {{ font-size:19px; color:var(--dim); max-width:62ch; margin:0 0 30px; }}

  .run {{ background:var(--panel); border:1px solid var(--line); border-radius:12px;
    padding:18px 20px; display:flex; gap:14px; align-items:center; flex-wrap:wrap; }}
  .run code {{ font-family:var(--mono); font-size:15px; color:var(--green); }}
  .run .step {{ color:var(--dim); font-size:13px; }}
  button.copy {{ margin-left:auto; background:var(--green); color:#04301f; border:0;
    border-radius:8px; padding:9px 16px; font-weight:700; cursor:pointer; font-size:14px; }}
  button.copy:hover {{ filter:brightness(1.08); }}

  .cta {{ display:flex; gap:12px; flex-wrap:wrap; margin-top:22px; }}
  .cta a {{ text-decoration:none; border:1px solid var(--line); border-radius:9px;
    padding:11px 18px; font-weight:600; font-size:15px; background:var(--panel); }}
  .cta a.primary {{ background:var(--violet); border-color:var(--violet); }}
  .cta a:hover {{ border-color:var(--dim); }}

  section {{ padding:52px 0; border-bottom:1px solid var(--line); }}
  h2 {{ font-size:24px; margin:0 0 8px; letter-spacing:-.01em; }}
  .sub {{ color:var(--dim); margin:0 0 24px; max-width:66ch; }}

  pre.demo {{ background:#05070b; border:1px solid var(--line); border-radius:12px;
    padding:20px; overflow-x:auto; font-family:var(--mono); font-size:13px;
    line-height:1.55; color:#c7d0de; margin:0; }}

  .filters {{ display:flex; gap:8px; flex-wrap:wrap; margin:0 0 18px; }}
  .pill {{ background:var(--panel); color:var(--dim); border:1px solid var(--line);
    border-radius:999px; padding:7px 14px; font-size:13.5px; cursor:pointer; font-weight:600; }}
  .pill[aria-pressed="true"] {{ background:var(--ink); color:var(--bg); border-color:var(--ink); }}
  input.search {{ flex:1; min-width:190px; background:var(--panel); border:1px solid var(--line);
    border-radius:999px; padding:8px 16px; color:var(--ink); font-size:14px; }}

  .loop {{ display:flex; gap:14px; align-items:flex-start; text-decoration:none;
    padding:13px 15px; border:1px solid var(--line); border-radius:10px;
    background:var(--panel); margin-bottom:8px; }}
  .loop:hover {{ border-color:var(--dim); }}
  .loop .num {{ font-family:var(--mono); font-size:13px; color:var(--dim);
    min-width:26px; padding-top:2px; }}
  .loop .body {{ flex:1; min-width:0; }}
  .loop .name {{ display:block; font-weight:650; }}
  .loop .looks {{ display:block; color:var(--dim); font-size:13.5px; }}
  .star {{ color:var(--amber); margin-left:7px; }}
  .ready {{ margin-left:8px; font-size:11px; font-weight:700; letter-spacing:.05em;
    text-transform:uppercase; color:var(--green); border:1px solid var(--green);
    border-radius:4px; padding:1px 5px; vertical-align:1px; }}
  .tag {{ font-size:12px; font-weight:700; white-space:nowrap; padding-top:3px; }}
  .tag.ships {{ color:var(--green); }}
  .tag.flags {{ color:var(--violet); }}
  .count {{ color:var(--dim); font-size:13.5px; margin:14px 0 0; }}

  footer {{ padding:40px 0 70px; color:var(--dim); font-size:14.5px; }}
  footer a {{ color:var(--ink); }}
  @media (max-width:620px) {{
    .loop {{ flex-wrap:wrap; }} .tag {{ padding-top:0; }}
  }}
</style>
</head>
<body>

<header><div class="wrap">
  <h1><small>The Warship CTO</small>From Prompt to Loop</h1>
  <p class="lede">{total} loops that keep a product alive after it ships. A loop finds its own
  work, hands it to an agent, checks the result, and writes down what it learned. You build it
  once. It runs without you after that.</p>

  <div class="run">
    <span class="step">Node 18 and bash. No API key, no AWS account.</span>
    <code id="cmd">git clone {repo}.git &amp;&amp; cd From-Prompt-to-Loop &amp;&amp; ./run-all-demos.sh</code>
    <button class="copy" id="copy">Copy</button>
  </div>

  <div class="cta">
    <a class="primary" href="{repo}#readme">Open the repo</a>
    <a href="{repo}/blob/main/docs/00-start-here.md">Read this first</a>
    <a href="{repo}/blob/main/docs/01-what-is-a-loop.md">What a loop is</a>
    <a href="{repo}/raw/main/From-Prompt-to-Loop_The-Warship-CTO.pdf">The field guide (free PDF)</a>
  </div>
</div></header>

<section><div class="wrap">
  <h2>This is what that one command prints</h2>
  <p class="sub">Real checks, on a real project, finding real problems. Nothing mocked for the
  screenshot. A demo that exits non zero has not failed: that is the check saying there is work.</p>
  <pre class="demo">{demo}</pre>
</div></section>

<section><div class="wrap">
  <h2>The {total} loops</h2>
  <p class="sub"><strong>Ships on green</strong> opens a PR and merges once the check passes, and a
  bad one is one click back. <strong>Flags, you decide</strong> stops and hands you the call.
  Nothing irreversible happens without a person. ★ marks the three easiest first builds.</p>

  <div class="filters">
    {chapter_pills}
    <button class="pill" data-f="tag" data-v="ships">Ships on green</button>
    <button class="pill" data-f="tag" data-v="flags">Flags, you decide</button>
    <button class="pill" data-f="ready" data-v="1">Runnable today</button>
    <input class="search" id="q" type="search" placeholder="Search the loops&hellip;" aria-label="Search the loops">
  </div>

  <div id="list">
{cards}
  </div>
  <p class="count" id="count"></p>
</div></section>

<footer><div class="wrap">
  <p><strong>Start with loop 2, dependency upgrades.</strong> The check only reads, the change is a
  version bump, and the PR is easy to review. If it gets it wrong you close the PR and nothing
  happened. <a href="{repo}/blob/main/docs/04-your-first-loop.md">The ten minute walkthrough</a>.</p>
  <p>MIT licensed. Built by <a href="https://mariosfakiolas.com">Marios Fakiolas</a>, who writes The
  Warship CTO. Crews, not committees. Loops, not turns.</p>
</div></footer>

<script>
(function () {{
  var copy = document.getElementById('copy');
  copy.addEventListener('click', function () {{
    var t = document.getElementById('cmd').textContent;
    navigator.clipboard.writeText(t).then(function () {{
      copy.textContent = 'Copied'; setTimeout(function () {{ copy.textContent = 'Copy'; }}, 1600);
    }});
  }});

  var on = {{}}, q = document.getElementById('q');
  var loops = [].slice.call(document.querySelectorAll('.loop'));
  var count = document.getElementById('count');

  function apply() {{
    var term = (q.value || '').trim().toLowerCase(), shown = 0;
    loops.forEach(function (el) {{
      var ok = true;
      for (var f in on) {{ if (on[f] && el.dataset[f] !== on[f]) ok = false; }}
      if (ok && term && el.dataset.q.indexOf(term) === -1) ok = false;
      el.style.display = ok ? '' : 'none';
      if (ok) shown++;
    }});
    count.textContent = shown + ' of ' + loops.length + ' loops';
  }}

  [].slice.call(document.querySelectorAll('.pill')).forEach(function (b) {{
    b.addEventListener('click', function () {{
      var f = b.dataset.f, v = b.dataset.v, was = on[f] === v;
      [].slice.call(document.querySelectorAll('.pill[data-f="' + f + '"]'))
        .forEach(function (o) {{ o.setAttribute('aria-pressed', 'false'); }});
      on[f] = was ? null : v;
      b.setAttribute('aria-pressed', was ? 'false' : 'true');
      apply();
    }});
  }});
  q.addEventListener('input', apply);
  apply();
}})();
</script>
</body>
</html>
"""

if __name__ == "__main__":
    sys.exit(main())
