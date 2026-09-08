# Agentic AI @ UIUC — lecture decks

presenterm decks, one per Monday lecture, published to GitHub Pages. Read
`README.md` for the scripts and `template/PATTERNS.md` for the slide cookbook.

## How every deck is built

These come from presenting to this club. They are not style preferences; they
are what works in the room.

1. **Fewer words.** People come to listen, not read. A slide carries one visual
   and one claim. Everything else goes in the speaker note. Content slides:
   under 50 words of prose. Titles: five words or fewer.
2. **Visuals over text.** Ask "what is the picture?" before writing a sentence.
   ASCII diagrams, tables, and comparisons beat paragraphs. A slide with no
   visual needs a reason.
3. **An AI market update slide** near the top of every deck. Three or four
   items from the last few weeks, each with a source and a date, plus one
   question to open discussion. Research it fresh each week; it goes stale.
4. **Real business examples.** Explain concepts through companies that
   actually do the thing. Name the company, say what they do with it, keep it
   to one line. Never invent an example — if unsure it's real, drop it.
5. **Big type.** The Siebel Center for Design screens are small. Export at a
   narrow column count, present with the terminal font turned up, and let
   word count fall to make room. Nothing below the fold, ever.

## presenterm rules that bite

- Comment commands are parsed as YAML. A `: ` inside a `speaker_note`, or a
  note starting with `"`, fails the build. Use a dash instead.
- `Title\n===` is a slide title. `# Title` is a body heading. Decks use `===`.
- Colors come from palette classes in `shared/theme/agentic-ai.yaml`
  (`kicker`, `accent`, `muted`, `dim`, `badge`, `good`, `bad`). Never a hex
  in a deck.
- `jump_to_middle` starts content at the vertical center. Use it only on
  divider slides with nothing but a kicker and a title.
- ASCII diagrams must stay under 90 columns. Wider wraps on the projector.
- `+exec` demos are stdlib-only, offline, deterministic, with a `__main__`
  self-check. They live in `moduleNN/demo/`.

## Before anything ships

`scripts/check.sh` must pass. It validates overflow at export size and at the
tight size, and runs every demo's self-check. Overflow is the failure you
cannot see until you are on stage.

## Commits

One intent per commit, Conventional Commits, scopes `module01`, `site`,
`scripts`, `theme`, `template`, `ci`. A file touched by two intents is split
line-by-line, not lumped. Force-pushing is acceptable only to restructure
commits that were just pushed and nobody has pulled, and always say so.
