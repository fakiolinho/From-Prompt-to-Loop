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


# Shared by the landing page and every guide page, so the two cannot drift apart.
# Each face falls back to a system font, so the site still reads if Google Fonts is blocked.
FONTS = """<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Instrument+Sans:wght@400;600;700&family=JetBrains+Mono:wght@400;600&family=Unbounded:wght@500;600;700&display=swap">
<meta name="theme-color" content="#140c0b">"""

TOKENS = """  :root {
    --hull:#140c0b; --deck:#1c1210; --well:#0d0807; --rivet:#3a2622;
    --ink:#f1e4d8; --text:#d9c8bb; --dim:#a48d80;
    --red:#e6503d; --amber:#d9a441; --lamp:#86b86b;
    --display:"Unbounded","Helvetica Neue",Arial,sans-serif;
    --sans:"Instrument Sans",ui-sans-serif,-apple-system,"Segoe UI",Roboto,sans-serif;
    --mono:"JetBrains Mono",ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;
  }
  * { box-sizing:border-box; }
  body { margin:0; color:var(--text); font:17px/1.68 var(--sans);
    background:radial-gradient(90% 480px at 50% 0, rgba(230,80,61,.1), transparent) no-repeat, var(--hull); }
  a { color:var(--ink); text-decoration-color:var(--red); text-underline-offset:3px; }
  a:hover { color:var(--red); }
  :focus-visible { outline:2px solid var(--red); outline-offset:3px; }
  strong { color:var(--ink); }
  code { font-family:var(--mono); font-size:.86em; color:var(--amber); }
"""

PAGE = r"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title} &middot; From Prompt to Loop</title>
<meta name="description" content="{title}. Part of From Prompt to Loop, thirty five runnable loops that keep a product alive after it ships.">
{fonts}
<style>
  /* Night bridge: a warship's bridge after dark. Red light to see by, amber for the
     instruments, and one green lamp that only ever means "nothing to do". */
{tokens}
  .top {{ border-bottom:1px solid var(--rivet); background:var(--well); }}
  .top .wrap {{ display:flex; align-items:center; gap:16px; max-width:1120px; margin:0 auto; padding:14px 20px; }}
  .top a.home {{ color:var(--ink); text-decoration:none; font:700 15px/1.3 var(--display); letter-spacing:-.01em; }}
  .top .kicker {{ display:block; color:var(--red); font:600 13px/1.3 var(--sans); margin-bottom:2px; }}
  .top .gh {{ margin-left:auto; font-size:14.5px; }}

  .shell {{ display:grid; grid-template-columns:236px minmax(0,1fr);
    gap:56px; max-width:1120px; margin:0 auto; padding:40px 20px 90px; }}
  nav {{ position:sticky; top:24px; align-self:start; }}
  nav .lbl {{ color:var(--dim); font-size:13.5px; font-weight:600; margin:0 0 8px; }}
  nav a {{ display:flex; gap:12px; align-items:baseline; text-decoration:none; color:var(--dim);
    padding:6px 10px; border-left:2px solid transparent; font-size:15px; line-height:1.45; }}
  nav a em {{ font:500 11px/1 var(--display); color:var(--amber); opacity:.7; min-width:16px; }}
  nav a:hover {{ color:var(--ink); }}
  nav a.here {{ color:var(--ink); font-weight:600; border-left-color:var(--red); background:rgba(230,80,61,.1); }}
  nav a.here em {{ opacity:1; }}
  nav .loops {{ margin-top:22px; padding-top:18px; border-top:1px solid var(--rivet); }}

  article {{ min-width:0; max-width:760px; }}
  article h1 {{ font:700 clamp(26px,3.6vw,38px)/1.14 var(--display); color:var(--ink);
    letter-spacing:-.015em; margin:0 0 10px; }}
  .meta {{ color:var(--dim); font-size:14px; margin:0 0 34px; }}
  article h2 {{ font:500 22px/1.25 var(--display); color:var(--ink); letter-spacing:-.01em; margin:46px 0 12px; }}
  article h3 {{ font:700 18px/1.35 var(--sans); color:var(--ink); margin:32px 0 8px; }}
  article img {{ max-width:100%; height:auto; display:block; margin:28px 0; }}
  article hr {{ border:0; border-top:1px solid var(--rivet); margin:38px 0; }}
  article blockquote {{ margin:26px 0; padding:4px 0 4px 20px; border-left:2px solid var(--red); color:var(--ink); }}
  article code {{ background:var(--deck); border:1px solid var(--rivet); border-radius:3px; padding:1px 5px; }}
  article pre {{ background:var(--well); border:1px solid var(--rivet); border-radius:6px;
    padding:18px 20px; overflow-x:auto; }}
  article pre code {{ background:none; border:0; padding:0; font-size:13.5px; color:var(--text); line-height:1.65; }}
  .tw {{ overflow-x:auto; margin:24px 0; }}
  article table {{ border-collapse:collapse; width:100%; min-width:560px; font-size:15.5px; }}
  article th {{ text-align:left; color:var(--dim); font-size:14px; font-weight:600;
    padding:9px 13px; border-bottom:1px solid var(--dim); white-space:nowrap; }}
  article td {{ padding:11px 13px; border-bottom:1px solid var(--rivet); vertical-align:top; }}

  .pager {{ display:flex; justify-content:space-between; gap:16px; flex-wrap:wrap;
    margin-top:56px; padding-top:22px; border-top:1px solid var(--rivet); font-size:15.5px; }}
  .cta {{ margin-top:40px; background:var(--well); border:1px solid var(--rivet);
    border-left:3px solid var(--amber); border-radius:4px; padding:18px 22px; }}
  .cta p {{ margin:0 0 8px; color:var(--dim); font-size:15px; }}
  .cta code {{ font-size:14px; overflow-wrap:anywhere; }}

  @media (max-width:860px) {{
    .shell {{ grid-template-columns:1fr; gap:28px; }}
    nav {{ position:static; }}
    nav a {{ display:inline-flex; border-left:0; border-bottom:2px solid transparent; }}
    nav a.here {{ border-bottom-color:var(--red); }}
  }}
</style>
</head>
<body>

<div class="top"><div class="wrap">
  <a class="home" href="index.html"><span class="kicker">The Warship CTO</span>From Prompt to Loop</a>
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
    <p class="meta">Page {idx} of {total}</p>
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
    # a wide table scrolls inside its own box, so a phone never scrolls the whole page
    body = body.replace("<table>", '<div class="tw"><table>').replace("</table>", "</table></div>")

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
                       total=len(GUIDE) - 1, fonts=FONTS, tokens=TOKENS)

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
        f'<button class="pill" data-f="ch" data-v="{n}">{t}</button>'
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
        fonts=FONTS,
        tokens=TOKENS,
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
{fonts}
<style>
  /* Night bridge: see the note above PAGE. */
{tokens}
  .wrap {{ max-width:1000px; margin:0 auto; padding:0 20px; }}

  header {{ padding:84px 0 52px; border-bottom:1px solid var(--rivet); }}
  h1 {{ font:700 clamp(36px,7vw,68px)/1.02 var(--display); color:var(--ink); letter-spacing:-.025em; margin:0 0 26px; }}
  h1 small {{ display:block; font:600 16px/1.3 var(--sans); letter-spacing:0; color:var(--red); margin-bottom:18px; }}
  .lede {{ font-size:20px; line-height:1.55; max-width:58ch; margin:0 0 34px; }}

  .run {{ background:var(--well); border:1px solid var(--rivet); border-left:3px solid var(--amber);
    border-radius:4px; padding:16px 18px; display:flex; gap:10px 16px; align-items:center; flex-wrap:wrap; }}
  .run .step {{ flex-basis:100%; color:var(--dim); font-size:14.5px; }}
  .run code {{ flex:1 1 0; min-width:0; font-size:15px; overflow-wrap:anywhere; }}
  button.copy {{ margin-left:auto; background:none; color:var(--amber); border:1px solid var(--amber);
    border-radius:3px; padding:7px 16px; font:600 14px var(--sans); cursor:pointer; }}
  button.copy:hover {{ background:var(--amber); color:var(--hull); }}

  .cta {{ display:flex; gap:10px; flex-wrap:wrap; margin-top:26px; }}
  .cta a {{ text-decoration:none; border:1px solid var(--rivet); border-radius:3px;
    padding:11px 18px; font-weight:600; font-size:15.5px; }}
  .cta a:hover {{ border-color:var(--dim); color:var(--ink); }}
  .cta a.primary {{ background:var(--red); border-color:var(--red); color:#1a0806; }}
  .cta a.primary:hover {{ background:#f06a58; color:#1a0806; }}

  section {{ padding:64px 0; border-bottom:1px solid var(--rivet); }}
  h2 {{ font:500 clamp(22px,3vw,28px)/1.2 var(--display); color:var(--ink); letter-spacing:-.015em; margin:0 0 12px; }}
  .sub {{ margin:0 0 26px; max-width:66ch; }}

  .tw {{ overflow-x:auto; }}
  table {{ border-collapse:collapse; width:100%; font-size:15.5px; }}
  th {{ text-align:left; color:var(--dim); font-size:14px; font-weight:600; padding:9px 16px 9px 0;
    border-bottom:1px solid var(--dim); }}
  td {{ padding:12px 16px 12px 0; border-bottom:1px solid var(--rivet); vertical-align:top; }}

  pre.demo {{ background:var(--well); border:1px solid var(--rivet); border-radius:6px;
    padding:22px; overflow-x:auto; font:13px/1.6 var(--mono); color:var(--text); margin:0; }}

  /* The three answers as a lit indicator panel: the one loud thing on the page. */
  .answers {{ display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); background:var(--well);
    border:1px solid var(--rivet); border-radius:18px; padding:28px 8px;
    box-shadow:inset 0 0 0 6px var(--deck), inset 0 0 0 7px var(--rivet); }}
  .ans {{ --c:var(--lamp); padding:6px 24px; }}
  .ans + .ans {{ border-left:1px solid var(--rivet); }}
  .a1 {{ --c:var(--amber); }}
  .a2 {{ --c:var(--red); }}
  .ans b {{ display:flex; align-items:center; gap:12px; font:600 14px var(--mono); color:var(--c); }}
  .ans b::before {{ content:""; flex:none; width:14px; height:14px; border-radius:50%; background:var(--c);
    box-shadow:0 0 0 3px var(--well), 0 0 0 4px var(--rivet), 0 0 18px 3px var(--c);
    animation:lamp .45s ease-out both; }}
  .a1 b::before {{ animation-delay:.35s; }}
  .a2 b::before {{ animation-delay:.7s; }}
  @keyframes lamp {{ from {{ background:var(--rivet); box-shadow:0 0 0 3px var(--well), 0 0 0 4px var(--rivet); }} }}
  .ans span {{ display:block; font:500 19px/1.3 var(--display); color:var(--ink); margin:14px 0 6px; }}
  .ans em {{ font-style:normal; color:var(--dim); font-size:15px; }}

  .guide {{ display:grid; grid-template-columns:repeat(auto-fit,minmax(270px,1fr)); column-gap:36px; }}
  .guide a {{ display:flex; gap:14px; align-items:baseline; text-decoration:none;
    border-top:1px solid var(--rivet); padding:14px 0; font-weight:600; font-size:16.5px; }}
  .guide a:hover {{ border-top-color:var(--red); }}
  .guide a em {{ font:500 12px var(--display); color:var(--amber); min-width:18px; }}

  .filters {{ display:flex; gap:8px; flex-wrap:wrap; margin:0 0 20px; }}
  .pill {{ background:none; color:var(--dim); border:1px solid var(--rivet); border-radius:3px;
    padding:7px 13px; font:600 14px var(--sans); cursor:pointer; }}
  .pill:hover {{ color:var(--ink); border-color:var(--dim); }}
  .pill[aria-pressed="true"] {{ color:var(--amber); border-color:var(--amber); background:rgba(217,164,65,.1); }}
  input.search {{ flex:1; min-width:190px; background:var(--well); border:1px solid var(--rivet);
    border-radius:3px; padding:8px 14px; color:var(--ink); font:15px var(--sans); }}

  #list {{ border-bottom:1px solid var(--rivet); }}
  .loop {{ display:grid; grid-template-columns:52px minmax(0,1fr) auto; gap:4px 18px; align-items:baseline;
    text-decoration:none; padding:15px 6px; border-top:1px solid var(--rivet); }}
  .loop:hover {{ background:rgba(230,80,61,.06); color:inherit; }}
  .loop .num {{ font:600 20px/1 var(--display); color:var(--amber); font-variant-numeric:tabular-nums; }}
  .loop .name {{ display:block; font-weight:600; font-size:16.5px; color:var(--ink); }}
  .loop .looks {{ display:block; color:var(--dim); font-size:14.5px; line-height:1.5; margin-top:2px; }}
  .star {{ color:var(--amber); margin-left:8px; }}
  .ready {{ margin-left:10px; font-size:12.5px; font-weight:600; color:var(--lamp);
    border:1px solid rgba(134,184,107,.45); border-radius:3px; padding:0 6px; vertical-align:1px; }}
  .tag {{ display:flex; align-items:center; gap:8px; font-size:13.5px; font-weight:600; white-space:nowrap; }}
  .tag::before {{ content:""; width:8px; height:8px; border-radius:50%; background:currentColor; }}
  .tag.ships {{ color:var(--lamp); }}
  .tag.flags {{ color:var(--red); }}
  .count {{ color:var(--dim); font-size:14px; margin:14px 0 0; }}

  footer {{ padding:48px 0 80px; color:var(--dim); font-size:15px; }}
  footer p {{ max-width:68ch; }}

  @media (max-width:720px) {{
    .answers {{ grid-template-columns:1fr; padding:14px 4px; }}
    .ans {{ padding:16px 20px; }}
    .ans + .ans {{ border-left:0; border-top:1px solid var(--rivet); }}
    .loop {{ grid-template-columns:40px minmax(0,1fr); }}
    .tag {{ grid-column:2; }}
  }}
  @media (prefers-reduced-motion:reduce) {{
    .ans b::before {{ animation:none; }}
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
  <p class="sub" style="margin-top:22px"><a href="{repo}/blob/main/WIRING.md">WIRING.md</a> lists
  every setting all thirty five loops read. Anything you leave unset simply exits 2 and tells you
  what it wanted, so you can install everything and wire it up over weeks.</p>
</div></section>

<section><div class="wrap">
  <h2>What it costs, and what it needs</h2>
  <p class="sub">Most of this costs nothing. The part that spends money is one step, and it is
  fenced on four sides.</p>
  <div class="tw"><table>
    <tr><th></th><th>Needs</th><th>Costs</th></tr>
    <tr><td><code>./run-all-demos.sh</code> and every check</td><td>Node 18 and bash</td><td>nothing, ever</td></tr>
    <tr><td><code>./run-loop.sh 02</code> on your machine</td><td>your existing Claude Code or Codex login</td><td>whatever that run costs you</td></tr>
    <tr><td>The GitHub Actions runner</td><td>an API key in repo secrets</td><td>per token, metered</td></tr>
  </table></div>
  <p class="sub" style="margin-top:16px"><strong>Locally you do not need an API key.</strong> If
  you are already signed in to Claude Code, a subscription included, the runner uses that. There
  is nothing to buy to try this. A runner in CI has no login, so that one does need a key, and
  it is metered per token whatever your interactive plan says.</p>
  <p class="sub">Every agent run is capped at <code>--max-budget-usd 2</code> and
  <code>--max-turns 30</code>, with a 20 minute timeout. And the check runs first, so a loop with
  nothing to do never wakes an agent. A quiet night costs nothing.</p>
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
