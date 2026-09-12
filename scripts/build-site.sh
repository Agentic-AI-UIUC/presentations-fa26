#!/usr/bin/env bash
# Build the static site -> site/
#
#   site/index.html            gallery of every module
#   site/moduleNN/index.html   that module's own landing page
#   site/moduleNN/deck.html    the exported deck
#
# Each module gets its own URL path, so /module01/ is shareable on its own.
# Runs headless: shared/config.yaml pins export dimensions so no TTY is needed.
source "$(dirname "$0")/_common.sh"
OUT="$ROOT/site"
rm -rf "$OUT"; mkdir -p "$OUT"
cp "$ROOT/shared/assets/favicon.png" "$OUT/favicon.png"

SITE_NAME="Agentic AI @ UIUC"
SITE_TERM="FALL 2026"
INSTAGRAM='<a class="icon" href="https://www.instagram.com/agenticaiuiuc" target="_blank" rel="noopener" aria-label="Instagram" title="Instagram"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1" fill="currentColor" stroke="none"/></svg></a>'
LINKEDIN='<a class="icon" href="https://www.linkedin.com/company/agentic-ai-uiuc" target="_blank" rel="noopener" aria-label="LinkedIn" title="LinkedIn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="3" width="18" height="18" rx="3"/><path d="M8 10v7"/><circle cx="8" cy="7" r="1" fill="currentColor" stroke="none"/><path d="M12 17v-7"/><path d="M12 13c0-1.7 1.1-3 2.5-3S17 11.3 17 13v4"/></svg></a>'
LINKTREE='<a class="icon" href="https://linktr.ee/agenticaiuiuc" target="_blank" rel="noopener" aria-label="Linktree" title="Linktree"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 11 6 5"/><path d="M12 11l6-6"/><path d="M4 11h16"/><path d="M12 14v6"/></svg></a>' 

# Brand tokens, mirrored from shared/theme/agentic-ai.yaml.
css() {
cat <<'CSS'
<style>
  :root{--bg:#0d0d0d;--card:#1a1a1a;--border:#2e2e2e;--text:#f2f2f2;--muted:#9a9a9a;--dim:#6b6b6b;--orange:#f25c14;
        --mono:ui-monospace,SFMono-Regular,Menlo,monospace;
        --sans:ui-sans-serif,system-ui,-apple-system,"Segoe UI",sans-serif}
  *{box-sizing:border-box}
  html{font-size:clamp(15px,1.05vw,21px)}
  body{margin:0;background:var(--bg);color:var(--text);font:1rem/1.5 var(--sans);min-height:100vh}
  a{color:inherit}
  .wrap{width:min(100% - 2*clamp(20px,4vw,72px),1500px);margin:0 auto;min-height:100vh;
        display:flex;flex-direction:column;padding:clamp(32px,4vw,72px) 0 clamp(28px,3vw,48px)}
  .bar{display:flex;justify-content:space-between;align-items:center;gap:1rem;
       border-bottom:1px solid var(--border);padding-bottom:1rem;
       font:600 .8rem/1 var(--mono);letter-spacing:.08em}
  .bar a{color:var(--dim);text-decoration:none}
  .bar a:hover{color:var(--orange)}
  .kicker{color:var(--orange);font:600 .8rem/1 var(--mono);letter-spacing:.12em;margin:3.2rem 0 .75rem}
  h1{font-size:clamp(2.2rem,5vw,5rem);line-height:.98;letter-spacing:-.02em;margin:0 0 .8rem;text-transform:uppercase}
  .lede{color:var(--muted);font-size:1.15rem;margin:0 0 2.2rem;max-width:62ch}
  .grid{display:grid;gap:1rem;grid-template-columns:repeat(auto-fill,minmax(min(100%,22rem),1fr))}
  .card{display:block;background:var(--card);border:1px solid var(--border);border-radius:.75rem;
        padding:1.5rem;text-decoration:none;transition:border-color .15s,transform .15s}
  .card:hover{border-color:var(--orange);transform:translateY(-2px)}
  .card h2{font-size:1.2rem;margin:.3rem 0 .5rem;letter-spacing:-.01em}
  .card p{color:var(--muted);font-size:.9rem;margin:0}
  .cta{display:inline-block;background:var(--orange);color:#0d0d0d;text-decoration:none;
       border-radius:.5rem;padding:1rem 1.75rem;font:700 .85rem/1 var(--mono);letter-spacing:.08em}
  .cta:hover{filter:brightness(1.1)}
  .icon{display:flex;color:var(--dim)}
  .icon:hover{color:var(--orange)}
  .icon svg{width:1.1rem;height:1.1rem;display:block}
  footer{margin-top:auto;padding-top:1rem;border-top:1px solid var(--border);
         display:flex;justify-content:space-between;align-items:center;gap:1rem;
         color:var(--dim);font:.7rem/1 var(--mono);letter-spacing:.08em}
  footer a{color:inherit;text-decoration:none}
  footer a:hover{color:var(--orange)}
  footer .socials{display:flex;align-items:center;gap:.9rem}
</style>
CSS
}

# Pull a quoted front-matter value out of a deck.
meta() { sed -n "s/^$2: *\"\{0,1\}\(.*[^\"]\)\"\{0,1\} *$/\1/p" "$1" | head -1; }

cards=""
for deck in $(decks); do
  dir="$(dirname "$deck")"; name="$(basename "$dir")"
  echo "── $name"
  mkdir -p "$OUT/$name"

  (cd "$dir" && "$PRESENTERM" -c "$CONFIG" -x --image-protocol ascii-blocks \
      --export-html -o "$OUT/$name/deck.html" "$(basename "$deck")" </dev/null)

  if [ -f "$dir/export.py" ]; then
    python3 "$dir/export.py" "$OUT/$name/deck.html"
  fi

  title=$(meta "$deck" title);   sub=$(meta "$deck" sub_title)
  # "MODULE 01 · Foo" -> "Foo"; the kicker above the headline already says which module.
  headline=$(printf '%s' "$title" | sed 's/^MODULE *[0-9]* *· *//')
  date=$(meta "$deck" date)

  # Per-module landing page.
  { cat <<HTML
<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${title:-$name} · $SITE_NAME</title>
<meta name="description" content="${sub:-}">
<link rel="icon" type="image/png" href="../favicon.png">
HTML
    css
    cat <<HTML
</head><body><div class="wrap">
<div class="bar"><a href="../">← ALL LECTURES</a><span>$SITE_TERM</span></div>
<div class="kicker">/// $(printf '%s' "${name/module/MODULE }" | tr 'a-z-' 'A-Z ')</div>
<h1>${headline:-$name}</h1>
<p class="lede">${sub:-}</p>
<a class="cta" href="deck.html">OPEN THE DECK →</a>
<footer><span>AGENTIC AI @ UIUC · <a href="https://agenticaiuiuc.com">AGENTICAIUIUC.COM</a></span><span class="socials">$INSTAGRAM$LINKEDIN$LINKTREE</span></footer>
</div></body></html>
HTML
  } > "$OUT/$name/index.html"

  cards+="<a class=\"card\" href=\"$name/\"><h2>${title:-$name}</h2><p>${sub:-}</p></a>"
done

# Gallery.
{ cat <<HTML
<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Lectures · $SITE_NAME</title>
<link rel="icon" type="image/png" href="favicon.png">
HTML
  css
  cat <<HTML
</head><body><div class="wrap">
<div class="bar"><strong>AGENTIC AI @ UIUC</strong><span>$SITE_TERM</span></div>
<div class="kicker">/// LECTURE SERIES</div>
<h1>Lecture decks</h1>
<p class="lede">Our weekly lectures can be viewed below!</p>
<div class="grid">$cards</div>
<div style="height:4rem"></div>
<footer><span>AGENTIC AI @ UIUC · <a href="https://agenticaiuiuc.com">AGENTICAIUIUC.COM</a></span><span class="socials">$INSTAGRAM$LINKEDIN$LINKTREE</span></footer>
</div></body></html>
HTML
} > "$OUT/index.html"

echo "site ready: $OUT"
