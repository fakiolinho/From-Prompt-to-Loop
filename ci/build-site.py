#!/usr/bin/env python3
"""Generate the GitHub Pages site: docs/index.html plus the eight guide pages.

The markdown in docs/*.md stays the single source of truth. Nothing is written
twice, so nothing can drift. This script renders each page to HTML with the same
styling as the landing page, and rewrites the links so they work off GitHub:

    04-your-first-loop.md        ->  04-your-first-loop.html   (published here)
    ../README.md                 ->  index.html                (the contents page)
    ../loop-packs/.../ORDERS.md  ->  github.com/.../blob/main  (lives with the code)
    ../From-Prompt-to-Loop*.pdf  ->  github.com/.../raw/main   (the field guide)

The landing page's catalog comes from ci/guide-catalog.tsv and each chapter's
LOOPS.md, and its terminal output from a real run recorded in ci/demo-output.txt.

Run it, commit the result. ci/test-docs.sh fails if anything committed is stale.

Needs markdown-it-py. Everything else here is standard library.
"""
import glob, html, os, re, sys

from markdown_it import MarkdownIt

REPO = "https://github.com/fakiolinho/From-Prompt-to-Loop"
RAW  = REPO + "/raw/main"
BLOB = REPO + "/blob/main"

GUIDE = [
    ("00-start-here",      "Read this first"),
    ("01-what-is-a-loop",  "What a loop is"),
    ("02-plain-words",     "Plain words"),
    ("03-run-the-demos",   "Run the demos"),
    ("04-your-first-loop", "Your first loop"),
    ("05-add-the-next",    "Add the next one"),
    ("06-operating",       "Operating a fleet"),
    ("07-where-these-fit", "Where these fit"),
]
CHAPTERS = {
    "engineering-loops": (1, "Software engineering", "1-9"),
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


PAGE = r"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title} &middot; From Prompt to Loop</title>
<meta name="description" content="{title}. Part of From Prompt to Loop, thirty five runnable loops that keep a product alive after it ships.">
<style>
  :root {{
    --bg:#0b0e14; --panel:#131823; --line:#232b3b; --ink:#e6e9ef; --dim:#93a0b5;
    --amber:#f59e0b; --green:#10b981; --violet:#8b5cf6;
    --mono: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  }}
  * {{ box-sizing:border-box; }}
  body {{ margin:0; background:var(--bg); color:var(--ink);
    font:16.5px/1.72 ui-sans-serif,-apple-system,"Segoe UI",Roboto,sans-serif; }}
  a {{ color:#8ab4ff; }}
  a:hover {{ color:#b9d0ff; }}

  .top {{ border-bottom:1px solid var(--line); background:#090c12; }}
  .top .wrap {{ display:flex; align-items:center; gap:16px; padding:14px 20px; }}
  .top a.home {{ color:var(--ink); text-decoration:none; font-weight:700; }}
  .top .kicker {{ color:var(--amber); font-size:11.5px; font-weight:700;
    letter-spacing:.14em; text-transform:uppercase; }}
  .top .gh {{ margin-left:auto; font-size:14px; }}

  .shell {{ display:grid; grid-template-columns:246px minmax(0,1fr);
    gap:44px; max-width:1120px; margin:0 auto; padding:34px 20px 80px; }}
  nav {{ position:sticky; top:22px; align-self:start; }}
  nav .lbl {{ color:var(--dim); font-size:11.5px; font-weight:700;
    letter-spacing:.12em; text-transform:uppercase; margin:0 0 10px; }}
  nav a {{ display:flex; gap:10px; text-decoration:none; color:var(--dim);
    padding:7px 11px; border-radius:8px; font-size:14.5px; }}
  nav a em {{ font-style:normal; color:#55627a; font-family:var(--mono); font-size:12.5px; }}
  nav a:hover {{ background:var(--panel); color:var(--ink); }}
  nav a.here {{ background:var(--panel); color:var(--ink); font-weight:650;
    box-shadow:inset 2px 0 0 var(--amber); }}
  nav .loops {{ margin-top:20px; padding-top:16px; border-top:1px solid var(--line); }}

  article {{ min-width:0; }}
  article h1 {{ font-size:clamp(27px,4vw,38px); line-height:1.16; margin:0 0 6px;
    letter-spacing:-.02em; }}
  .meta {{ color:var(--dim); font-size:13.5px; margin:0 0 30px; }}
  article h2 {{ font-size:23px; margin:40px 0 10px; letter-spacing:-.01em; }}
  article h3 {{ font-size:18.5px; margin:30px 0 8px; }}
  article p, article li {{ color:#d3d9e4; }}
  article strong {{ color:var(--ink); }}
  article img {{ max-width:100%; height:auto; display:block; margin:26px 0; }}
  article hr {{ border:0; border-top:1px solid var(--line); margin:34px 0; }}
  article blockquote {{ margin:24px 0; padding:2px 20px; border-left:3px solid var(--amber);
    color:#c7d0de; font-style:italic; }}
  article code {{ font-family:var(--mono); font-size:.88em; background:var(--panel);
    border:1px solid var(--line); border-radius:5px; padding:1px 5px; }}
  article pre {{ background:#05070b; border:1px solid var(--line); border-radius:10px;
    padding:17px 19px; overflow-x:auto; }}
  article pre code {{ background:none; border:0; padding:0; font-size:13.2px;
    color:#c7d0de; line-height:1.62; }}
  .tw {{ overflow-x:auto; margin:22px 0; }}
  article table {{ border-collapse:collapse; width:100%; font-size:15px; }}
  article th {{ text-align:left; color:var(--dim); font-size:12.5px; font-weight:700;
    letter-spacing:.06em; text-transform:uppercase; padding:9px 13px;
    border-bottom:1px solid var(--line); white-space:nowrap; }}
  article td {{ padding:11px 13px; border-bottom:1px solid var(--line);
    vertical-align:top; color:#d3d9e4; }}

  .pager {{ display:flex; justify-content:space-between; gap:16px; flex-wrap:wrap;
    margin-top:52px; padding-top:22px; border-top:1px solid var(--line); font-size:15px; }}
  .cta {{ margin-top:34px; background:var(--panel); border:1px solid var(--line);
    border-radius:12px; padding:19px 21px; }}
  .cta p {{ margin:0 0 10px; color:var(--dim); font-size:14.5px; }}
  .cta code {{ color:var(--green); }}

  @media (max-width:860px) {{
    .shell {{ grid-template-columns:1fr; gap:26px; }}
    nav {{ position:static; }}
    nav a {{ display:inline-flex; }}
  }}
</style>
</head>
<body>

<div class="top"><div class="wrap">
  <a class="home" href="index.html"><span class="kicker">The Warship CTO</span><br>From Prompt to Loop</a>
  <span class="gh"><a href="{repo}">View on GitHub</a></span>
</div></div>

<div class="shell">
  <nav>
    <p class="lbl">The guide</p>
    {toc}
    <div class="loops">
      <p class="lbl">The loops</p>
      <a href="index.html#loops"><em>35</em>All chapters</a>
      <a href="{repo}/raw/main/From-Prompt-to-Loop_The-Warship-CTO.pdf"><em>pdf</em>Field guide</a>
    </div>
  </nav>

  <article>
    <h1>{title}</h1>
    <p class="meta">Page {idx} of {total} &middot; From Prompt to Loop</p>
    {body}

    <div class="cta">
      <p>Reading is the slow way round. This runs all four chapters against seeded data:</p>
      <code>git clone {repo}.git &amp;&amp; cd From-Prompt-to-Loop &amp;&amp; ./run-all-demos.sh</code>
    </div>

    <div class="pager">{prev}{next}</div>
  </article>
</div>

</body>
</html>
"""

# ---------------------------------------------------------------- guide pages

GUIDE_NAMES = {n for n, _ in GUIDE}

def rewrite(href):
    """Point a link written for GitHub at the right place on the published site."""
    if href.startswith(("http://", "https://", "mailto:", "#")):
        return href
    # a sibling guide page becomes its published HTML
    m = re.fullmatch(r"(\d\d-[a-z-]+)\.md(#.*)?", href)
    if m and m.group(1) in GUIDE_NAMES:
        return m.group(1) + ".html" + (m.group(2) or "")
    # the repo README is the contents page here
    if href in ("../README.md", "../README.md#the-four-chapters"):
        return "index.html"
    # the field guide is a binary in the repo
    if href.endswith(".pdf"):
        return RAW + "/" + href.lstrip("./").replace("../", "")
    # anything else in the repo lives with the code, on GitHub
    if href.startswith("../"):
        return BLOB + "/" + href[3:]
    return href

def render_page(name, title, idx):
    md = MarkdownIt("commonmark").enable(["table", "strikethrough"])
    tokens = md.parse(open(f"docs/{name}.md", encoding="utf-8").read())
    for t in tokens:
        for tok in ([t] + (t.children or [])):
            if tok.type in ("link_open", "image"):
                key = "href" if tok.type == "link_open" else "src"
                v = tok.attrGet(key)
                if v:
                    tok.attrSet(key, rewrite(v))
    body = md.renderer.render(tokens, md.options, {})
    # the page's own H1 becomes the header, so it is not repeated in the body
    body = re.sub(r"<h1>.*?</h1>\s*", "", body, count=1, flags=re.S)

    prev_l = (f'<a href="{GUIDE[idx-1][0]}.html">&larr; {html.escape(GUIDE[idx-1][1])}</a>'
              if idx > 0 else '<span></span>')
    next_l = (f'<a href="{GUIDE[idx+1][0]}.html">{html.escape(GUIDE[idx+1][1])} &rarr;</a>'
              if idx < len(GUIDE) - 1 else '<span></span>')
    toc = "".join(
        f'<a class="{"here" if n == name else ""}" href="{n}.html">'
        f'<em>{i}</em>{html.escape(t)}</a>'
        for i, (n, t) in enumerate(GUIDE))

    return PAGE.format(title=html.escape(title), body=body, toc=toc,
                       prev=prev_l, next=next_l, repo=REPO, idx=idx,
                       total=len(GUIDE) - 1)

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

    guide_links = "".join(
        f'<a href="{n}.html"><em>{i}</em>{html.escape(t)}</a>' for i, (n, t) in enumerate(GUIDE))

    page = TEMPLATE.format(
        repo=REPO,
        guide_links=guide_links,
        cards="\n".join(cards),
        chapter_pills=chapter_pills,
        demo=html.escape(demo.strip()),
        total=len(rows),
    )
    os.makedirs("docs", exist_ok=True)
    open("docs/index.html", "w").write(page)
    open("docs/.nojekyll", "w").write("")
    print(f"ok   docs/index.html written, {len(rows)} loops")

    for i, (name, title) in enumerate(GUIDE):
        open(f"docs/{name}.html", "w").write(render_page(name, title, i))
    print(f"ok   {len(GUIDE)} guide pages rendered to HTML")

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

  .answers {{ display:grid; grid-template-columns:repeat(auto-fit,minmax(238px,1fr)); gap:12px; }}
  .ans {{ background:var(--panel); border:1px solid var(--line); border-radius:12px; padding:16px 18px;
    border-top-width:3px; }}
  .ans b {{ display:block; font-family:var(--mono); font-size:14px; }}
  .ans span {{ display:block; font-weight:650; margin:2px 0 6px; }}
  .ans em {{ font-style:normal; color:var(--dim); font-size:14px; }}
  .a0 {{ border-top-color:var(--green); }} .a0 b {{ color:var(--green); }}
  .a1 {{ border-top-color:var(--blue); }}  .a1 b {{ color:var(--blue); }}
  .a2 {{ border-top-color:#e0668a; }}      .a2 b {{ color:#e0668a; }}

  .guide {{ display:grid; grid-template-columns:repeat(auto-fit,minmax(232px,1fr)); gap:10px; }}
  .guide a {{ display:flex; gap:12px; align-items:baseline; text-decoration:none;
    background:var(--panel); border:1px solid var(--line); border-radius:10px;
    padding:13px 16px; font-weight:600; }}
  .guide a:hover {{ border-color:var(--dim); }}
  .guide a em {{ font-style:normal; font-family:var(--mono); font-size:12.5px; color:var(--dim); }}

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
    <span class="step">See all four chapters find real work. Node 18 and bash, no API key, no AWS account.</span>
    <code id="cmd">git clone {repo}.git &amp;&amp; cd From-Prompt-to-Loop &amp;&amp; ./run-all-demos.sh</code>
    <button class="copy" id="copy">Copy</button>
  </div>

  <div class="run" style="margin-top:12px">
    <span class="step">Then put one in your own repo. It writes a loops.env with the settings that loop needs.</span>
    <code id="cmd2">./install.sh ~/code/my-app 02</code>
    <button class="copy" id="copy2">Copy</button>
  </div>

  <div class="cta">
    <a class="primary" href="{repo}#readme">Open the repo</a>
    <a href="00-start-here.html">Read this first</a>
    <a href="01-what-is-a-loop.html">What a loop is</a>
    <a href="{repo}/raw/main/From-Prompt-to-Loop_The-Warship-CTO.pdf">The field guide (free PDF)</a>
  </div>
</div></header>

<section><div class="wrap">
  <h2>A check has three answers, not two</h2>
  <p class="sub">Every loop starts with one question, and how it answers decides what you pay.
  The third answer is the one most people leave out, and it is the expensive one: a check with
  only two will say &ldquo;there is work&rdquo; when it means &ldquo;I cannot tell&rdquo;.</p>
  <div class="answers">
    <div class="ans a0"><b>exit 0</b><span>no work</span><em>The run ends. You spend nothing.</em></div>
    <div class="ans a1"><b>exit 1</b><span>there is work</span><em>The agent wakes, fenced and capped.</em></div>
    <div class="ans a2"><b>exit 2</b><span>not wired here</span><em>Fails loudly and says what it needs. No agent.</em></div>
  </div>
  <p class="sub" style="margin-top:18px"><a href="{repo}/blob/main/WIRING.md">WIRING.md</a> lists
  every setting all thirty five loops read. Anything you leave unset simply exits 2 and tells you
  what it wanted, so you can install everything and wire it up over weeks.</p>
</div></section>

<section><div class="wrap">
  <h2>The guide</h2>
  <p class="sub">Eight short pages. None longer than a screen or two. Read them in order the
  first time, then come back to whichever one you need.</p>
  <div class="guide">{guide_links}</div>
</div></section>

<section><div class="wrap">
  <h2>This is what that one command prints</h2>
  <p class="sub">Real checks, on a real project, finding real problems. Nothing mocked for the
  screenshot. A demo that exits non zero has not failed: that is the check saying there is work.</p>
  <pre class="demo">{demo}</pre>
</div></section>

<section id="loops"><div class="wrap">
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
  happened. <a href="04-your-first-loop.html">The ten minute walkthrough</a>.</p>
  <p>MIT licensed. Built by <a href="https://mariosfakiolas.com">Marios Fakiolas</a>, who writes The
  Warship CTO. Crews, not committees. Loops, not turns.</p>
</div></footer>

<script>
(function () {{
  [['copy','cmd'], ['copy2','cmd2']].forEach(function (pair) {{
    var btn = document.getElementById(pair[0]), src = document.getElementById(pair[1]);
    if (!btn || !src) return;
    btn.addEventListener('click', function () {{
      navigator.clipboard.writeText(src.textContent).then(function () {{
        btn.textContent = 'Copied'; setTimeout(function () {{ btn.textContent = 'Copy'; }}, 1600);
      }});
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
