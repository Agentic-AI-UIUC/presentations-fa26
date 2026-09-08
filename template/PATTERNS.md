# Deck patterns — Agentic AI @ UIUC

Copy-paste snippets. The brand system in one page: **near-black canvas, orange
accent, white condensed titles, muted-gray supporting copy, monospace kickers.**

All colors come from `shared/theme/agentic-ai.yaml`. Never hardcode a hex in a
deck — use a palette class so a theme change propagates everywhere.

---

## Palette classes

| Class | Use it for |
|---|---|
| `kicker` | The `/// SECTION` line above a slide title |
| `accent` | Orange emphasis: numbers, key nouns |
| `muted` | Supporting copy, card body text |
| `dim` | Parentheticals, attributions, footnotes |
| `badge` | Black-on-orange pill — one per slide, maximum |
| `tag` | Gray-on-card chip, for tech-stack rows |
| `good` / `bad` | Green ✔ / red ✘ markers |

```markdown
<span class="accent">**01**</span>
<span class="muted">supporting copy</span>
<span class="badge"> ONE IDEA </span>
<span class="good">✔</span> works    <span class="bad">✘</span> does not
```

---

## Slide header

Every content slide opens the same way: kicker, then a setext title. The `===`
underline is what makes presenterm use the slide-title style (big, bold, ruled)
— a `#` heading is a *body* heading and renders differently.

```markdown
<span class="kicker">/// THE VOCABULARY PROBLEM</span>

FOUR WORDS PEOPLE CONFUSE
===

<span class="muted">Optional one-line subtitle.</span>
```

## Section divider

```markdown
<!-- jump_to_middle -->

<span class="kicker">/// PART 02</span>

THE LOOP
===
```

---

## Layouts

### Cards (2–5 across)

```markdown
<!-- column_layout: [1, 1, 1] -->

<!-- column: 0 -->
<span class="accent">**01**</span>

**CARD TITLE**

<span class="muted">Body.</span>

<!-- column: 1 -->
...

<!-- reset_layout -->
```

Weights are ratios, so `[1, 3]` gives a narrow gutter and a wide body — that is
the numbered-list layout used on every "run of show" slide.

### Bad vs good

Two columns, `bad` on the left, `good` on the right, fenced code in each.
Always show the wrong version first; the contrast is the teaching.

### Callout

A block quote renders as an orange-ruled card. Use it for **one** takeaway per
slide, and put it after a `<!-- pause -->` so people read the evidence first.

```markdown
<!-- pause -->

> The takeaway sentence.
```

---

## Reveals

```markdown
<!-- pause -->          reveal the rest of the slide on the next keypress
<!-- new_line -->       one blank line (markdown collapses repeats)
<!-- new_lines: 2 -->   n blank lines
```

Pauses become separate pages in the exported HTML (`export.pauses: new_slide`
in `shared/config.yaml`), so the web version reveals like the live one.

---

## Code

Static, syntax-highlighted:

````markdown
```python
def run_agent(goal, tools): ...
```
````

Live-executable — press `Ctrl-E` during the talk:

````markdown
```python +exec
import sys; sys.path.insert(0, "demo")
from mini_agent import run_agent
run_agent("...")
```
````

Rules for exec demos:

- Keep them **offline and deterministic**. No API keys, no network, no wifi
  dependency. Stub the model; the loop is what you are teaching.
- Put the code in `moduleNN/demo/` and import it — never inline more than
  three lines on the slide.
- Give the demo file an `if __name__ == "__main__"` self-check so a broken
  demo fails in CI, not on stage.
- Paths are relative to the deck directory (the scripts `cd` there first).

ASCII diagrams go in a ```` ```text ```` block. They render identically
everywhere and cost nothing to edit — prefer them to images.

---

## Speaker notes and comments

```markdown
<!-- speaker_note: Timing, fallbacks, the thing you always forget to say. -->
<!-- // A note to yourself. Never rendered. -->
```

Present with notes on a second screen: `scripts/present.sh 01 --publish-speaker-notes`
and, in another terminal, `presenterm --listen-speaker-notes`.

---

## House style

- Slide titles: **caps, short, a claim not a label.** "WORKFLOW vs AGENT" beats
  "About Workflows".
- One idea per slide. If it needs two block quotes, it is two slides.
- Muted gray carries detail; white carries the point. If everything is white,
  nothing is emphasized.
- Prefer a table to a bullet list whenever the content has two dimensions.
- Cut any slide you cannot say the purpose of in one sentence.

---

## Checks before presenting

```bash
scripts/check.sh          # parses every deck, flags overflow, runs demo self-checks
scripts/present.sh 01     # dry run at your real terminal size
```

`--validate-overflows` catches slides taller than the terminal — the single
most common failure, and invisible until you are on stage.
