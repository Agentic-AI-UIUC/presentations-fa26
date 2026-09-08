# Lecture decks — Agentic AI @ UIUC

Terminal-native slide decks built with [presenterm](https://github.com/mfontanini/presenterm).
Markdown in, live-executable code demos, and a static site published to GitHub Pages on
every push to `main`.

```
presentations-fa26/
├── shared/
│   ├── theme/agentic-ai.yaml   brand theme — colors, headings, footer
│   ├── config.yaml             presenterm config (export size, snippet exec)
│   ├── config-tight.yaml       100x30 — the overflow check that matters
│   └── assets/                 logo and shared images
├── template/
│   ├── MODULE_TEMPLATE.md      skeleton for a new lecture
│   └── PATTERNS.md             snippet cookbook + house style
├── scripts/
│   ├── present.sh NN           present a module
│   ├── new-module.sh NN "..."  scaffold a module from the template
│   ├── check.sh                parse decks, catch overflow, run demo self-checks
│   ├── build-site.sh           export every deck to site/moduleNN/
│   └── serve.sh                build + serve the site on localhost
├── module01/
│   ├── module01.md
│   └── demo/mini_agent.py
└── .github/workflows/pages.yml
```

## Setup

```bash
cargo install presenterm     # or: brew install presenterm
```

Nothing else. Demos are stdlib-only Python with no API keys and no network.

## Present

```bash
scripts/present.sh 01
```

| Key | Action |
|---|---|
| `→` `space` `j` | next |
| `←` `k` | previous |
| `Ctrl-E` | run the `+exec` code block on the current slide |
| `Ctrl-P` | slide index |
| `Ctrl-R` | reload from disk (edit live, mid-talk) |
| `q` | quit |

Speaker notes on a second screen:

```bash
scripts/present.sh 01 --publish-speaker-notes
presenterm --listen-speaker-notes      # in another terminal
```

Ghostty and kitty render this best — they support the font-size protocol, so slide
titles come out large. Other terminals degrade to normal-size text and still work.

## New module

```bash
scripts/new-module.sh 02 "Tool calling and structured outputs"
```

Then read `template/PATTERNS.md` — it has every layout used in module 01 as a
copy-paste snippet, plus the house style rules.

## Before you present

```bash
scripts/check.sh
```

Parses every deck, runs each demo's self-check, and validates overflow twice — at
export size and at 100x30, the smallest terminal worth presenting on. Overflow is
the failure you cannot see until you are on stage and the room's projector is not
your 32-inch monitor.

## Preview the site locally

```bash
scripts/serve.sh          # builds, then serves on http://localhost:8080
scripts/serve.sh 3000     # any port
```

Plain `python3 -m http.server` over the `site/` directory. There is deliberately
no framework here: the site is two generated pages and a favicon, and
`build-site.sh` is the whole static-site generator. Re-run after editing a deck.

## Deployment

**One repo, one Pages site, one page per module.** GitHub Pages allows exactly one
site per repository, so every module lives at its own path on the same site:

```
<pages-url>/                 gallery of every module
<pages-url>/module01/        module 01's landing page  ← the link you share
<pages-url>/module01/deck.html   the deck itself
<pages-url>/module02/        …and so on
```

Each module has its own URL and its own landing page, so it is shareable on its own —
but the theme, template, and scripts live in one place, and adding a module is still
one command. Every push republishes the whole site atomically.

`.github/workflows/pages.yml` runs `check.sh`, then `build-site.sh`, then publishes
`site/`. Pull requests build and validate but do not deploy.

One-time repo setup: `git init` at this directory, push, then
**Settings ➜ Pages ➜ Source ➜ GitHub Actions.**

The export runs headless because `shared/config.yaml` pins `export.dimensions` —
without it, presenterm sizes pages from the terminal and fails with no TTY attached.
`export.pauses: new_slide` makes each `<!-- pause -->` its own page, so the web
version reveals the same way the live one does.

### Presenterm in CI

The workflow builds presenterm from source with `cargo install`, pinned to
`PRESENTERM_VERSION`, and caches the resulting binary keyed on that version. The
first run compiles it (~5 minutes); every run afterwards restores the cached binary
in seconds. Bumping the version invalidates the cache and recompiles once.

## Gotchas

- **Comment commands are parsed as YAML.** A `: ` inside a `speaker_note`, or a note
  that starts with `"`, is a build failure. Reword — use a dash instead of a colon.
- **`===` under a line makes it a slide title.** A `#` heading is a body heading and
  looks different. The template uses `===` everywhere on purpose.
- **Colors belong in the theme, never in a deck.** Use the palette classes
  (`kicker`, `accent`, `muted`, `dim`, `badge`, `good`, `bad`) so a brand change is
  one file.
- **`+exec` needs `-x`.** `scripts/present.sh` passes it. Running `presenterm`
  directly will show the snippet as "not started" and nothing will happen.
- **Demo paths are relative to the deck directory.** The scripts `cd` there first;
  if you run presenterm by hand from elsewhere, imports in `+exec` blocks break.

## Modules

| Deck | Covers |
|---|---|
| `module01` | Agentic AI foundations, prompting, and tool calling. Opens with why agents now (the 2022-26 arc, the plateau argument, where they already work), then what an LLM does, tokens and sampling, agent vs workflow, the harness, the ReAct loop, context and failure modes, six prompting rules, tool calling and structured outputs, and a live 40-line agent demo. ~90 pages with reveals; 60 minutes if you keep moving, and the cut order is in the first slide's speaker note. |
