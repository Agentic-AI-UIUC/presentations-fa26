---
title: "54 WORKSHOP · DEMOS THAT SURVIVE THE PITCH"
sub_title: "Three files that keep Cursor on your product and off the commands that wreck a demo."
event: "FOUNDERS 54 · FALL 2026 · AGENTIC AI @ UIUC"
location: "Sunset Studio"
date: "4 PM"
theme:
  path: ../shared/theme/agentic-ai.yaml
options:
  end_slide_shorthand: false
---

<span class="kicker">/// RUN OF SHOW</span>

THE NEXT 45 MINUTES
===

<span class="accent">**01**</span>  **Why demos die** · <span class="muted">Two failure modes</span>

<span class="accent">**02**</span>  **Three files** · <span class="muted">Rule, skill, hook</span>

<span class="accent">**03**</span>  **Hands-on** · <span class="muted">Clone, trip the hook, make it yours</span>

<span class="accent">**04**</span>  **Prove it** · <span class="muted">One number, one video</span>

<!-- pause -->

<!-- new_line -->

> By Sunday 3 PM your demo **runs on stage** and your pitch has **one honest number**.

<!-- speaker_note: 45 min. Budget is 5 / 15 / 15 / 5 plus Q&A. Builders do part 02 and 03. Founders own the one-flow sentence and part 04. Say that up front so nobody checks out. Cut order if long - Spotify slide, then the second market item. -->

<!-- end_slide -->

<span class="kicker">/// THIS MONTH</span>

WHAT SHIPPED
===

| | What | Why it matters tonight |
|---|---|---|
| **Aug 11** | Spotify open-sources `portal-ai-plugins` | Hooks that gate file reads, in production |
| **Sep 10** | Cursor CLI `2026.09.10` | `agent` in the terminal, hooks and skills load |
| **Sep** | Cursor loads the Agent Plugins open standard | One `plugin.json`, three editors |

<!-- pause -->

<!-- new_line -->

> If Spotify needs guardrails around its coding agent, what does your two-day demo need?

<!-- speaker_note: Sources - github.com/spotify/portal-ai-plugins commit history, agent --version, cursor.com/docs/plugins. Thirty seconds each. The question is rhetorical, move on. -->

<!-- end_slide -->

<span class="kicker">/// FRAMING</span>

THE ONE THING
===

<span class="muted">Cursor will build something this weekend. The question is whether it is your product.</span>

<!-- new_lines: 2 -->

<span class="badge"> THE ONE THING TO REMEMBER </span>

<!-- new_line -->

**Guard Cursor. It builds your product, and only your product.**

<!-- end_slide -->

<!-- jump_to_middle -->

<span class="kicker">/// PART 01</span>

WHY DEMOS DIE
===

<!-- end_slide -->

<span class="kicker">/// TWO WAYS</span>

DRIFT OR DAMAGE
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

<span class="bad">**✘ DRIFT**</span>

**Cursor builds a generic app.**

<span class="muted">Adds auth you did not ask for. Swaps your stack. Ships features that are not on the pitch slide.</span>

<!-- column: 1 -->

<span class="bad">**✘ DAMAGE**</span>

**Cursor does something dumb at 2 AM.**

<span class="muted">Force push. `rm -rf`. Reads `.env` into context and pastes it into a log.</span>

<!-- reset_layout -->

<!-- pause -->

<!-- new_line -->

> Both are fixable in under an hour. Three small files.

<!-- speaker_note: Ask for hands on each. Everyone has seen drift. Half the room has lost work to damage. That is the whole motivation, do not belabor it. -->

<!-- end_slide -->

<span class="kicker">/// SCOPE</span>

ONE FLOW
===

<span class="muted">Judges see three minutes. Pick one.</span>

<!-- new_line -->

```text
User types      ______________________
Product does    ______________________
Screen shows    ______________________
```

<!-- pause -->

<!-- new_line -->

> Everything else is a slide, not a demo. **Founders, write this sentence tonight.**

<!-- speaker_note: This is the non-technical half of the room's job. Twenty words max. If a team cannot fill the three blanks they do not have a demo yet, they have a feature list. -->

<!-- end_slide -->

<!-- jump_to_middle -->

<span class="kicker">/// PART 02</span>

THREE FILES
===

<!-- end_slide -->

<span class="kicker">/// THE SYSTEM</span>

RULE, SKILL, HOOK
===

<!-- column_layout: [1, 1, 1] -->

<!-- column: 0 -->

<span class="accent">**01**</span>

**RULE**

<span class="muted">`.cursor/rules/`</span>

<span class="muted">Your spec. In context on every prompt.</span>

<span class="tag"> SOFT </span>

<!-- column: 1 -->

<span class="accent">**02**</span>

**SKILL**

<span class="muted">`.cursor/skills/`</span>

<span class="muted">How to run the demo. Loaded when relevant.</span>

<span class="tag"> SOFT </span>

<!-- column: 2 -->

<span class="accent">**03**</span>

**HOOK**

<span class="muted">`.cursor/hooks/`</span>

<span class="muted">Runs before the action. Allow or deny.</span>

<span class="badge"> HARD </span>

<!-- reset_layout -->

<!-- pause -->

<!-- new_line -->

> Rule says what to build. Skill says how to use it. Hook says **never**.

<!-- speaker_note: Land soft versus hard. A rule is a suggestion the model usually follows. A hook is bash that runs before the action and returns allow or deny. The model cannot talk its way past it. Anything that would embarrass you on stage goes in the hook. -->

<!-- end_slide -->

<span class="kicker">/// RULE 01</span>

WRITE THE SPEC ONCE
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

<span class="bad">**✘ WRONG**</span>

```text
"build me a dashboard for
 trucking logistics"
```

<span class="muted">Every prompt starts from zero. Cursor guesses.</span>

<!-- column: 1 -->

<span class="good">**✔ RIGHT**</span>

```markdown
alwaysApply: true

User types a pickup and drop.
App returns one priced route.
Screen shows the route + price.

- Only this flow.
- No auth, no DB.
- Never touch .env.
```

<!-- reset_layout -->

<!-- pause -->

> Under twenty lines. `product.mdc` is read on **every** prompt.

<!-- speaker_note: LIVE - switch to the terminal, cd into the repo, run agent, ask "what are we building". It quotes product.mdc. Then ask it to add login. Watch it push back. That is the rule working. -->

<!-- end_slide -->

<span class="kicker">/// RULE 02</span>

THE GATE IS BASH
===

```json
{
  "version": 1,
  "hooks": {
    "beforeShellExecution": [
      { "command": ".cursor/hooks/guard.sh", "failClosed": true }
    ],
    "beforeReadFile": [
      { "command": ".cursor/hooks/guard.sh", "failClosed": true }
    ]
  }
}
```

<!-- pause -->

> JSON in on stdin. `allow` or `deny` out. Forty lines of bash, no framework.

<!-- speaker_note: LIVE - ask the agent to run rm -rf on a fake path. Show the deny message verbatim. Open guard.sh, point at BLOCK_CMDS. Then the next slide runs the self-check. failClosed means a crashed hook blocks instead of allowing. -->

<!-- end_slide -->

<span class="kicker">/// LIVE</span>

PROVE THE GATE
===

<span class="muted">Eight assertions, plain bash, no Cursor needed. Press `Ctrl-E`.</span>

```bash +exec
bash demo/test.sh
```

<!-- speaker_note: Fallback if exec misbehaves is running bash demo/test.sh in a second terminal. Green means the same script that Cursor calls is doing what the slide says. -->

<!-- end_slide -->

<span class="kicker">/// IN PRODUCTION</span>

SPOTIFY DOES THIS
===

<span class="muted">`plugins/shunt` in `spotify/portal-ai-plugins`. A hook blocks reads over 350 lines and routes them to a cheaper model.</span>

<!-- new_line -->

| Scenario | Lines | Without | With | Saved |
|---|---|---|---|---|
| Single large file | 4,014 | 33,684 tok | 5,737 tok | **82%** |
| Source + test pair | 7,408 | 75,990 tok | 4,148 tok | **94%** |
| Cross-service | 1,281 | 16,221 tok | 821 tok | **94%** |

<!-- pause -->

> Same shape as your `guard.sh`. Hook, script, skill. Fifty-one evals, no API key.

<!-- speaker_note: Numbers are from the shunt README benchmark table, measured on a 162K-line Java monorepo. Co-authored by Claude, which gets a laugh. One sentence and move on, this slide is the first cut if running long. -->

<!-- end_slide -->

<!-- jump_to_middle -->

<span class="kicker">/// PART 03</span>

HANDS-ON
===

<!-- end_slide -->

<span class="kicker">/// TWELVE MINUTES</span>

MAKE IT YOURS
===

```bash
git clone https://github.com/Agentic-AI-UIUC/54-workshop.git
cd 54-workshop && agent
```

<!-- new_line -->

<span class="accent">**01**</span>  Ask **"force push to main"**. <span class="muted">Watch it deny.</span>

<span class="accent">**02**</span>  Edit `.cursor/rules/product.mdc`. <span class="muted">Your flow, your stack.</span>

<span class="accent">**03**</span>  Rename `.cursor/skills/your-product/`. <span class="muted">Fill in `SKILL.md`.</span>

<span class="accent">**04**</span>  Ask **"build the flow in product.mdc"**.

<!-- speaker_note: Leave this slide up and walk. Common failures - python3 missing on Windows, use WSL or Git Bash. Hook not firing, restart Cursor, it caches hooks.json. Rule ignored, check alwaysApply is true. -->

<!-- end_slide -->

<!-- jump_to_middle -->

<span class="kicker">/// PART 04</span>

PROVE IT
===

<!-- end_slide -->

<span class="kicker">/// SLIDE 3 OF YOUR PITCH</span>

ONE HONEST NUMBER
===

| Task | Without your product | With it | Delta |
|---|---|---|---|
| Book a truck load | 14 min, 3 tools | 40 s, 1 prompt | **95%** |
| | | | |

<!-- pause -->

<!-- new_line -->

> One measured row beats ten adjectives. Judges will ask **how you measured it**.

<!-- speaker_note: Hands off to the Sunday 12:20 pitching workshop. PITCH.md in the repo has this table and a line for the method. Measure one thing tonight, seconds or clicks or tokens. -->

<!-- end_slide -->

<span class="kicker">/// INSURANCE</span>

THE VIDEO RULE
===

<span class="accent">**01**</span>  **Sunday 1 PM.** <span class="muted">Record 90 seconds of the flow working. Keep it on the laptop.</span>

<span class="accent">**02**</span>  **Demo dies on stage.** <span class="muted">Play the video. Keep talking.</span>

<span class="accent">**03**</span>  **Never debug in front of judges.** <span class="muted">Nobody has ever won by fixing a bug live.</span>

<!-- speaker_note: This is the slide people thank you for on Sunday. Say it slowly. -->

<!-- end_slide -->

<span class="kicker">/// RECAP</span>

THE THREE THINGS
===

<!-- new_line -->

<span class="accent">**01**</span>  A **rule** so Cursor builds your product, not a generic app.

<span class="accent">**02**</span>  A **hook** so nothing breaks the night before.

<span class="accent">**03**</span>  A **number** and a **video** so the pitch survives contact with judges.

<!-- end_slide -->

<span class="kicker">/// BEFORE SUNDAY 3 PM</span>

TONIGHT
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

<span class="badge"> DO </span>

**1. One-flow sentence** <span class="muted">in `product.mdc`</span>

**2. Fill in `SKILL.md`** <span class="muted">rename the folder</span>

**3. Your three forbidden commands** <span class="muted">in `guard.sh`, run `test.sh`</span>

**4. Measure one number**

<!-- column: 1 -->

<span class="badge"> SUNDAY </span>

<span class="muted">— 1 PM, record the video</span>

<span class="muted">— Table on slide 3</span>

<span class="muted">— 3 PM, pitch</span>

<!-- reset_layout -->

<!-- new_line -->

> `github.com/Agentic-AI-UIUC/54-workshop` · same checklist in `PITCH.md`

<!-- end_slide -->

<!-- jump_to_middle -->

<span class="kicker">/// 54 WORKSHOP COMPLETE</span>

QUESTIONS?
===

<span class="muted">Find me in the Sunday 1 to 3 work session if a hook will not fire.</span>

<!-- new_lines: 2 -->

<span class="badge"> AGENTICAIUIUC.COM </span>   <span class="dim">·</span>   <span class="muted">github.com/Agentic-AI-UIUC/54-workshop</span>
