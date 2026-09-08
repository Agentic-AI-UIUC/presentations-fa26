---
title: "MODULE 01 · AGENTIC AI FOUNDATIONS, PROMPTING, & TOOL CALLING"
sub_title: "What an agent actually is, why the loop is the whole idea, and how to write the prompts and tools it acts on!"
event: "AGENTIC AI @ UIUC · FALL 2026 LECTURE SERIES"
date: "TUE SEP 08"
theme:
  path: ../shared/theme/agentic-ai.yaml
options:
  end_slide_shorthand: false
---

<!-- end_slide -->

<span class="kicker">/// RUN OF SHOW</span>

TONIGHT
===

<span class="muted">Dense hour, and it builds — every part depends on the one before it. Slides go up right after, so do not try to transcribe.</span>

<!-- new_line -->

<!-- column_layout: [1, 3] -->

<!-- column: 0 -->

<span class="accent">**01**</span>

<span class="accent">**02**</span>

<span class="accent">**03**</span>

<span class="accent">**04**</span>

<span class="accent">**05**</span>

<!-- column: 1 -->

**What an agent actually is** — <span class="muted">tokens, the four words people confuse, and where the line is</span>

**The loop** — <span class="muted">think, act, observe, repeat — and the five ways it breaks</span>

**Prompting basics** — <span class="muted">six rules that survive contact with reality</span>

**Tool calling + structured outputs** — <span class="muted">how an agent touches the real world</span>

**Live demo** — <span class="muted">an agent in 40 lines, no framework</span>

<!-- reset_layout -->

<!-- pause -->

<!-- new_line -->

> **Interrupt me.** No ML background needed — if you can read a Python for-loop you can build an agent. By the end you should be able to look at any "AI product" and say what it is: a chatbot, a workflow, or an agent, and why that matters.

<!-- new_line -->

<span class="badge"> THE ONE THING TO REMEMBER TONIGHT </span>

<!-- new_line -->

**An agent is not a smarter model. An agent is a model you put inside a loop and gave hands.**

<!-- speaker_note: 60 min for merged weeks 1+2. Budget is 15 / 10 / 13 / 14 / 6 plus Q&A. Cut in this order if long - autonomy ladder, then anti-patterns, then how many and how big. Thursday Sep 10 is Business Workflow Automation 101, laptops open. -->

<!-- end_slide -->

<!-- jump_to_middle -->

<span class="kicker">/// PART 01</span>

WHAT IS AN AGENT?
===

<!-- end_slide -->

<span class="kicker">/// THE VOCABULARY PROBLEM</span>

FOUR WORDS PEOPLE USE INTERCHANGEABLY
===

<span class="muted">They are not the same thing, and the difference is the whole course.</span>

<!-- new_line -->

| Term | What it actually means | Who decides what happens next |
|---|---|---|
| **Model** | A function: tokens in, tokens out | Nothing. It has no "next" |
| **Chatbot** | Model + conversation history | The human, every turn |
| **Workflow** | Model calls wired together **in code you wrote** | You. The path is fixed |
| **Agent** | Model that picks its own tools and its own stopping point | The **model**, at runtime |

<!-- pause -->

<!-- new_line -->

> The dividing line: **who owns control flow.** If you can draw the flowchart before it runs, it is a workflow. If the flowchart is decided while it runs, it is an agent.

<!-- speaker_note: Push on this. Most "AI agents" being sold right now are workflows. That is not an insult — workflows are usually the correct choice. -->

<!-- end_slide -->

<span class="kicker">/// START FROM THE BOTTOM</span>

WHAT AN LLM ACTUALLY DOES
===

An LLM is a function. It takes a sequence of tokens and returns a probability distribution over the next token.

<!-- new_line -->

```text
   "The capital of Illinois is"  ──►  [ LLM ]  ──►   Springfield  71%
                                                     Chicago      22%
                                                     the           3%
                                                     ...
```

<!-- pause -->

<!-- new_line -->

**Sample** one. Append it. Feed it back in. Repeat.

<!-- new_line -->

**That is the entire mechanism.** Everything else — reasoning, coding, tool use, "agency" — is that loop plus structure around it.

<!-- pause -->

<!-- new_line -->

> Note the word **sample.** It does not pick the top token every time; it draws from the distribution. That knob is **temperature** — 0 is near-greedy and repeatable, higher is more varied. **This is the root of every "why did it answer differently?" you will ever ask.**

<!-- speaker_note: Do NOT let people leave thinking the model is magic. The magic is in the harness. -->

<!-- end_slide -->

<span class="kicker">/// THE UNIT OF EVERYTHING</span>

TOKENS
===

<span class="muted">Models do not read characters or words. Text is chopped into **tokens** — frequent chunks learned from the training data. Roughly **4 characters, or ¾ of a word**, in English.</span>

<!-- new_line -->

```text
  "Agentic AI @ UIUC is unbelievable"

   Ag | entic |  AI |  @ |  U | I | UC |  is |  unbeliev | able
   └──────────────── 10 tokens, 33 characters ────────────────┘

   common word  -> 1 token       "the", " is"
   rare word    -> many tokens   "unbeliev|able"
   code, JSON   -> token-hungry  every brace and indent costs
   non-English  -> 2-3x more tokens for the same meaning
```

<!-- pause -->

<!-- new_line -->

<!-- column_layout: [1, 1, 1] -->

<!-- column: 0 -->

**YOU PAY PER TOKEN**

<span class="muted">In *and* out. An agent's cost is a token count, not a request count.</span>

<!-- column: 1 -->

**LIMITS ARE IN TOKENS**

<span class="muted">"200K context" means tokens, not words or characters.</span>

<!-- column: 2 -->

**IT EXPLAINS THE QUIRKS**

<span class="muted">Bad at counting letters in a word or doing digit-level math — it never saw the letters.</span>

<!-- reset_layout -->

<!-- speaker_note: Live demo option if there is time - open the tokenizer playground and paste a student's name. The 3x for non-English is a good hook. -->

<!-- end_slide -->

<span class="kicker">/// THE GAP</span>

WHAT A RAW MODEL CANNOT DO
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

**It cannot act**

<span class="muted">It emits text. It cannot send an email, query your DB, or hit an API. Text is not action.</span>

<!-- new_line -->

**It cannot remember**

<span class="muted">Every call is stateless. "Memory" is you re-sending the transcript each time.</span>

<!-- column: 1 -->

**It cannot know anything new**

<span class="muted">Frozen at training cutoff. It does not know your codebase, today's date, or your users.</span>

<!-- new_line -->

**It cannot check its work**

<span class="muted">No ground truth, no execution, no feedback. Confident and wrong look identical.</span>

<!-- reset_layout -->

<!-- pause -->

<!-- new_line -->

> Every one of these four gaps is closed by the same move: **give the model a tool and put it in a loop.** That move is the agent.

<!-- end_slide -->

<span class="kicker">/// THE DEFINITION</span>

AGENT = MODEL + TOOLS + LOOP
===

```text
                   ┌──────────────────────────────────┐
                   │                                  │
                   ▼                                  │
   GOAL ──►  ┌───────────┐   picks a tool   ┌──────────────┐
             │   THINK   │ ───────────────► │     ACT      │
             │  (model)  │                  │ (run tool)   │
             └───────────┘                  └──────────────┘
                   ▲                                  │
                   │        result appended to        │
                   └───────  OBSERVE  ◄───────────────┘
                            (context)
                                 │
                        done? ───┴──► ANSWER
```

<!-- pause -->

<!-- new_line -->

<span class="muted">Three properties make it an agent, not a script:</span>
**(1)** the model chooses the action · **(2)** it sees the result · **(3)** it decides when to stop.

<!-- speaker_note: Draw this on the board too if there is one. This diagram is 80% of the lecture. -->

<!-- end_slide -->

<span class="kicker">/// CALIBRATION</span>

THE AUTONOMY LADDER
===

| | Level | Who owns the control flow | Example |
|---|---|---|---|
| **L0** | Chat | Human, every turn | ChatGPT in a browser |
| **L1** | Tool-augmented call | Human triggers, model fills args | "Summarize this PDF" |
| **L2** | Workflow / chain | **Your code**, fixed order | Transcribe ➜ summarize ➜ email |
| **L3** | Router | Your code owns the graph, model picks the branch | Support ticket triage |
| **L4** | **Agent** | **The model**, at runtime | Claude Code, Cursor agent mode |
| **L5** | Multi-agent | Agents spawn and coordinate agents | Research swarm, planner + workers |

<!-- pause -->

<!-- new_line -->

> Climbing the ladder buys you flexibility and costs you predictability, latency, and dollars. **Most production systems that work today live at L2–L3.**

<!-- end_slide -->

<span class="kicker">/// THE MOST IMPORTANT SLIDE</span>

WORKFLOW vs AGENT
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

<span class="badge"> WORKFLOW </span>

LLM calls orchestrated through **predefined code paths**.

<span class="muted">You wrote the steps. The model fills in the blanks.</span>

<!-- new_line -->

<span class="good">✔</span> predictable · testable · cheap
<span class="good">✔</span> fails in ways you can debug
<span class="good">✔</span> latency you can quote to a customer

<span class="bad">✘</span> breaks on inputs you did not anticipate

<!-- column: 1 -->

<span class="badge"> AGENT </span>

LLM **dynamically directs its own process** and tool use.

<span class="muted">You wrote the tools. The model writes the plan.</span>

<!-- new_line -->

<span class="good">✔</span> handles open-ended, unknown-shape tasks
<span class="good">✔</span> recovers from its own errors

<span class="bad">✘</span> non-deterministic, hard to test
<span class="bad">✘</span> 10–100× the tokens
<span class="bad">✘</span> can loop, stall, or take a bad action

<!-- reset_layout -->

<!-- pause -->

> **Default to the simplest thing that works.** Single prompt ➜ workflow ➜ agent. Only climb when the tier below actually fails.

<!-- speaker_note: This framing is from Anthropic's "Building Effective Agents" (Dec 2024). Worth reading before Thursday. -->

<!-- end_slide -->

<span class="kicker">/// RESTRAINT</span>

WHEN NOT TO BUILD AN AGENT
===

<!-- new_line -->

<span class="bad">✘</span> **The steps are always the same.** That is a function. Write the function.

<span class="bad">✘</span> **You need the same output every time.** Agents are non-deterministic by construction.

<span class="bad">✘</span> **A wrong action is expensive or irreversible.** Money moved, emails sent, rows deleted.

<span class="bad">✘</span> **Latency budget is under a second.** An agent loop is 3–30+ model calls.

<span class="bad">✘</span> **You cannot describe success.** If you cannot write the eval, you cannot ship the agent.

<!-- pause -->

<!-- new_lines: 2 -->

> The most senior move in this space is deleting an agent and replacing it with 40 lines of ordinary code. You will do this at least once this semester.

<!-- end_slide -->

<span class="kicker">/// ANATOMY</span>

THE FIVE PARTS OF ANY AGENT
===

<!-- column_layout: [1, 1, 1, 1, 1] -->

<!-- column: 0 -->
<span class="accent">**01**</span>

**MODEL**

<span class="muted">The reasoning engine. Swappable. Rarely your bottleneck.</span>

<!-- column: 1 -->
<span class="accent">**02**</span>

**INSTRUCTIONS**

<span class="muted">The system prompt. This is your policy, your rules, your persona.</span>

<!-- column: 2 -->
<span class="accent">**03**</span>

**TOOLS**

<span class="muted">Functions the model may call. Its hands. Its only way to touch reality.</span>

<!-- column: 3 -->
<span class="accent">**04**</span>

**MEMORY**

<span class="muted">Context window (short) + a store you retrieve from (long).</span>

<!-- column: 4 -->
<span class="accent">**05**</span>

**HARNESS**

<span class="muted">The loop itself: turn limits, retries, error handling, guardrails.</span>

<!-- reset_layout -->

<!-- pause -->

<!-- new_line -->

> Beginners spend 90% of their effort on **01**. The systems that actually work are won on **02, 03, and 05**. That ordering is the thesis of this entire course.

<!-- end_slide -->

<span class="kicker">/// DEFINE YOUR TERMS</span>

WHAT IS A "HARNESS"?
===

<span class="muted">The word gets used constantly and defined almost never. It is simply: **all the ordinary code that surrounds the model call.**</span>

<!-- new_line -->

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

<span class="badge"> THE HARNESS OWNS </span>

<span class="muted">— The **loop** and its turn limit</span>
<span class="muted">— **Executing** tool calls the model requests</span>
<span class="muted">— **Retries**, timeouts, rate limits</span>
<span class="muted">— **Guardrails**: what is allowed to run at all</span>
<span class="muted">— **Logging** every turn so you can debug</span>
<span class="muted">— Assembling context: what to send, what to drop</span>

<!-- column: 1 -->

<span class="badge"> WHY IT MATTERS </span>

The model is a **stateless function you rent.** It has no memory, no permissions, no ability to run anything.

<!-- new_line -->

Every safety property your system has, the harness enforces — because **the model can only ask.**

<!-- new_line -->

<span class="muted">Claude Code is a harness. Cursor is a harness. The 12 lines you will see in tonight's demo are a harness.</span>

<!-- reset_layout -->

<!-- pause -->

> Same model, different harness, wildly different product. **That gap is where your engineering goes.**

<!-- end_slide -->

<!-- jump_to_middle -->

<span class="kicker">/// PART 02</span>

THE LOOP
===

<!-- end_slide -->

<span class="kicker">/// THE CANONICAL PATTERN</span>

ReAct: REASON + ACT
===

<span class="muted">Yao et al., 2022. Still the backbone of nearly every agent you will use.</span>

<!-- new_line -->

```text
USER      What was the high in Champaign yesterday, in Celsius?

THOUGHT   I need yesterday's date first, then the weather.
ACTION    get_date({"offset_days": -1})
OBSERVE   "2026-09-07"

THOUGHT   Now fetch the high for that date.
ACTION    get_weather({"city": "Champaign, IL", "date": "2026-09-07"})
OBSERVE   {"high_f": 81, "low_f": 63}

THOUGHT   81F -> (81-32)*5/9 = 27.2C. I have the answer. Stop.
ANSWER    Yesterday's high in Champaign was 81F (27.2C).
```

<!-- pause -->

<span class="muted">Note: the model did **not** know the date. It did **not** know the weather. It knew **which questions to ask.** That is the skill being deployed.</span>

<!-- end_slide -->

<span class="kicker">/// MECHANICS</span>

WHAT A "TOOL" ACTUALLY IS
===

<span class="muted">A tool is a JSON schema you hand the model, plus a function you run when it asks. Nothing more.</span>

```json
{
  "name": "get_weather",
  "description": "Get the recorded high and low temperature for a city on a past date.
                  Use for historical weather only; it cannot forecast.",
  "input_schema": {
    "type": "object",
    "properties": {
      "city": { "type": "string", "description": "City and state, e.g. 'Champaign, IL'" },
      "date": { "type": "string", "description": "ISO date, YYYY-MM-DD" }
    },
    "required": ["city", "date"]
  }
}
```

<!-- pause -->

> The model never runs your code. It emits **a request to run it**. Your harness decides whether to comply. That gap is where every guardrail you will ever write lives.

<!-- end_slide -->

<span class="kicker">/// MECHANICS</span>

WHAT GOES OVER THE WIRE
===

<span class="muted">One agent turn is two HTTP requests. There is no magic layer.</span>

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

**REQUEST 1 ➜ model**

```text
system:  You are a weather assistant.
user:    High in Champaign yesterday?
tools:   [get_date, get_weather]
```

**RESPONSE 1 ◄ model**

```text
stop_reason: "tool_use"
tool_use:
  name: get_date
  input: {"offset_days": -1}
```

<!-- column: 1 -->

**REQUEST 2 ➜ model** <span class="muted">(you append the result)</span>

```text
system:  ...
user:    High in Champaign yesterday?
assistant: [tool_use get_date ...]
user:    [tool_result "2026-09-07"]
```

**RESPONSE 2 ◄ model**

```text
stop_reason: "tool_use"
tool_use:
  name: get_weather
  ...
```

<!-- reset_layout -->

<!-- pause -->

> Every loop iteration **resends the entire conversation.** Nothing persists on the server. This single fact explains agent cost, latency, and context limits.

<!-- end_slide -->

<span class="kicker">/// THE REAL CONSTRAINT</span>

THE CONTEXT WINDOW IS YOUR RAM
===

<!-- column_layout: [3, 2] -->

<!-- column: 0 -->

Everything the model can "see" this turn, measured in tokens:

<span class="muted">system prompt + tool schemas + full transcript + every tool result so far</span>

<!-- new_line -->

```text
  turn 1   [sys 500][tools 800][msg 40]                        1,340 tok
  turn 2   [sys 500][tools 800][msg 40][call+result 2,100]     3,440 tok
  turn 3   [ ..................................... ]           6,900 tok
  turn 8   [ ..................................... ]          31,000 tok
                                            billed each turn ──┘
```

Because you resend it all each turn, a 12-step run pays for step 1's context **twelve times.** That is why an agent costs 10–100× a single call.

<!-- new_line -->

**Failure mode with a name: context rot.** As the window fills with tool output, your instructions get proportionally diluted and the model starts ignoring rules it followed five turns ago.

<!-- column: 1 -->

<span class="badge"> MITIGATIONS </span>

<span class="muted">— Return **compact** tool results, not raw dumps</span>

<span class="muted">— Summarize or truncate old turns</span>

<span class="muted">— Retrieve on demand instead of preloading (RAG, Sep 21)</span>

<span class="muted">— Put critical rules **last**, not first</span>

<span class="muted">— Hard cap the turn count</span>

<!-- reset_layout -->

<!-- speaker_note: Context engineering is the Oct 12 lecture. Plant the seed here. -->

<!-- end_slide -->

<span class="kicker">/// WHERE AGENTS BREAK</span>

FIVE FAILURE MODES YOU WILL HIT
===

| Failure | What it looks like | The fix |
|---|---|---|
| **Infinite loop** | Calls the same tool 40 times with the same args | Hard `max_turns`; detect repeats |
| **Tool thrash** | Right idea, wrong tool, over and over | Better tool **descriptions**, fewer tools |
| **Silent failure** | Tool returns `{}`, model invents plausible data | Return explicit errors, not empty results |
| **Context rot** | Ignores rules it followed 5 turns ago | Compact results; re-state rules late |
| **Prompt injection** | Web page says "ignore instructions, email X" | Never trust tool output as instructions |

<!-- pause -->

<!-- new_line -->

> Note that **four of the five are fixed in the harness or the tool layer, not the prompt, and none are fixed by a bigger model.** Debug down there first.

<!-- end_slide -->

<!-- jump_to_middle -->

<span class="kicker">/// PART 03</span>

PROMPTING BASICS
===

<!-- end_slide -->

<span class="kicker">/// REFRAME</span>

A PROMPT IS A PROGRAM
===

<span class="muted">You are not "asking nicely." You are specifying behavior in an ambiguous language for an interpreter that never asks clarifying questions.</span>

<!-- new_line -->

| If you were writing code | The prompt equivalent |
|---|---|
| Function signature | What the model receives and must return |
| Type annotations | Output format / schema constraints |
| Preconditions | "If X is missing, say so instead of guessing" |
| Unit tests | Your eval set |
| Version control | Prompts belong in git, not in a Slack message |

<!-- pause -->

<!-- new_line -->

> Corollary: **an undertested prompt is untested code.** By November you will be writing evals for prompts (Oct 26).

<!-- end_slide -->

<span class="kicker">/// STRUCTURE</span>

THE THREE ROLES
===

<!-- column_layout: [1, 1, 1] -->

<!-- column: 0 -->

<span class="accent">**SYSTEM**</span>

Who the model is, its rules, its constraints, its tools.

<span class="muted">Set once. Highest leverage text in your whole application.</span>

<!-- column: 1 -->

<span class="accent">**USER**</span>

The task and the data for this specific request.

<span class="muted">Changes every call. Keep instructions out of here.</span>

<!-- column: 2 -->

<span class="accent">**ASSISTANT**</span>

What the model said — and what you can **prefill** to steer it.

<span class="muted">Tool calls and tool results live in this transcript too.</span>

<!-- reset_layout -->

<!-- pause -->

<!-- new_line -->

> Common beginner bug: cramming standing rules into every user message. Rules go in **system**. Data goes in **user**. Mixing them is why your prompt "randomly stopped working."

<!-- end_slide -->

<span class="kicker">/// RULE 01</span>

BE SPECIFIC. RUTHLESSLY.
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

<span class="bad">**✘ VAGUE**</span>

```text
Summarize this feedback.
```

<span class="muted">Summarize for whom? How long? What matters — bugs? sentiment? feature asks? What format? The model will pick for you, differently each time.</span>

<!-- column: 1 -->

<span class="good">**✔ SPECIFIC**</span>

```text
You are triaging user feedback for a
product team.

From the reviews below, extract every
distinct BUG report.

For each: one-line description, the
affected feature, severity (high /
medium / low).

Ignore praise and feature requests.
Output a markdown table, max 10 rows,
sorted by severity.
```

<!-- reset_layout -->

<!-- pause -->

> Test: **could two competent humans, given only your prompt, produce meaningfully different outputs?** If yes, keep specifying.

<!-- end_slide -->

<span class="kicker">/// RULE 02</span>

SHOW, DON'T TELL
===

<span class="muted">Three good examples beat three paragraphs of description. Format is learned far more reliably than it is described.</span>

<!-- new_line -->

```text
Extract the meeting request from each message.

Message: "can we do tues at 3?"
Output:  {"day": "Tuesday", "time": "15:00", "confidence": "high"}

Message: "sometime next week works"
Output:  {"day": null, "time": null, "confidence": "low"}

Message: "Thursday morning, before 10"
Output:  {"day": "Thursday", "time": "<10:00", "confidence": "medium"}

Message: "{{ input }}"
Output:
```

<!-- pause -->

<!-- new_line -->

> Pick examples that cover the **edges**, not the easy case. Example two above is doing all the work: it teaches the model what to do when there is no answer.

<!-- end_slide -->

<span class="kicker">/// RULE 03</span>

GIVE IT ROOM TO THINK
===

The model computes in tokens. Force an answer on token one and you get its first instinct. Ask for reasoning first and you get a better answer.

<!-- new_line -->

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

<span class="bad">**✘ NO ROOM**</span>

```text
Is this refund request valid?
Answer yes or no.
```

<!-- column: 1 -->

<span class="good">**✔ ROOM**</span>

```text
Is this refund request valid?

In <thinking> tags: check the
purchase date against the 30-day
window, then check the item
category against the exclusion list.

Then give your verdict in
<verdict> tags: VALID or INVALID,
one sentence of justification.
```

<!-- reset_layout -->

<!-- pause -->

<span class="muted">Modern reasoning models do much of this internally — but structured thinking still helps, and the tags make the output **parseable and auditable.**</span>

<!-- end_slide -->

<span class="kicker">/// RULE 04</span>

CONSTRAIN THE OUTPUT
===

<span class="muted">If a program consumes the output, an unconstrained prompt is a parsing bug waiting to happen.</span>

<!-- new_line -->

<span class="bad">**✘**</span> `"Give me the results as JSON"` <span class="muted">— you will get prose, then a fenced block, then an apology.</span>

<!-- new_line -->

<span class="good">**✔**</span> Escalate in this order:

<span class="muted">**1.** State the exact schema, with field types and an example</span>
<span class="muted">**2.** `"Respond with only the JSON object. No preamble, no code fences."`</span>
<span class="muted">**3.** Prefill the assistant turn with `{` so it cannot start with prose</span>
<span class="muted">**4.** Use the API's structured-output / tool-schema mode — the model is constrained at **decode time** and cannot emit invalid JSON</span>

<!-- pause -->

<!-- new_line -->

> **4 beats 1–3 and it is not close.** We come back to exactly how in Part 04.

<!-- end_slide -->

<span class="kicker">/// RULE 05</span>

GIVE IT AN EXIT
===

A model with no permitted failure state will invent a success state. That is most of what people call "hallucination."

<!-- new_line -->

```text
Answer using ONLY the context below.

If the context does not contain the answer, reply exactly:
  "NOT_IN_CONTEXT"

Do not use outside knowledge. Do not guess. Do not infer
across documents. A wrong answer is far worse than
NOT_IN_CONTEXT.
```

<!-- pause -->

<!-- new_line -->

Three moves, always:

<span class="muted">**1.** Name the escape hatch explicitly · **2.** Give it an exact literal to emit · **3.** Say the cost asymmetry out loud</span>

<!-- new_line -->

> This one line is the difference between a demo and a system you would put in front of a real user.

<!-- end_slide -->

<span class="kicker">/// RULE 06</span>

PROMPTING FOR AGENTS IS DIFFERENT
===

<span class="muted">Everything above still holds. But in an agent, your highest-leverage prompt is not the system prompt.</span>

<!-- new_line -->

> **Tool descriptions are prompts.** They are the only thing the model reads when choosing what to do. A vague description is a wrong tool call, every time.

<!-- pause -->

<!-- new_line -->

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

<span class="bad">**✘**</span>

```python
"description": "Searches."
```

<!-- column: 1 -->

<span class="good">**✔**</span>

```python
"description": (
  "Full-text search over internal "
  "support tickets from the last 18 "
  "months. Returns up to 10 matches "
  "with ticket id, title, status. "
  "Use for 'has this been reported' "
  "questions. Does NOT search code, "
  "docs, or Slack."
)
```

<!-- reset_layout -->

<span class="muted">Say what it does, what it returns, **when to reach for it**, and — critically — what it does **not** cover. Part 04 is entirely about getting this right.</span>

<!-- end_slide -->

<span class="kicker">/// PUTTING IT TOGETHER</span>

AN AGENT SYSTEM PROMPT, ANNOTATED
===

```text
You are a support triage agent for the Agentic AI @ UIUC help desk.   # role

GOAL                                                                  # one goal
Resolve the student's question, or escalate it. Nothing else.

PROCEDURE                                                             # rough plan,
1. Search past tickets before answering.                              # not rigid
2. If a past ticket matches, cite its id.                             # steps
3. If confidence is low, escalate. Do not speculate.

RULES                                                                 # hard limits
- Never invent a ticket id or a policy.
- Never take an action that emails a human without confirming first.
- If the answer is not in the tools, say NEEDS_HUMAN and stop.

STOPPING                                                              # termination
You are done when you have posted an answer or said NEEDS_HUMAN.
Never call the same tool twice with identical arguments.
```

<!-- pause -->

<span class="muted">Five blocks: **role · goal · procedure · rules · stopping condition.** Most broken agents are missing the last one.</span>

<!-- end_slide -->

<span class="kicker">/// ANTI-PATTERNS</span>

THINGS THAT DO NOT WORK
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

<span class="bad">✘</span> **Politeness as a strategy**
<span class="muted">"please please be accurate" is not a spec</span>

<span class="bad">✘</span> **Threats and bribes**
<span class="muted">"I'll tip $200" — measure it; it is noise</span>

<span class="bad">✘</span> **Contradictory rules**
<span class="muted">"be thorough but under 50 words"</span>

<span class="bad">✘</span> **The 3,000-word system prompt**
<span class="muted">rule #47 is not being followed and you cannot tell which one it is</span>

<!-- column: 1 -->

<span class="bad">✘</span> **Negative-only instructions**
<span class="muted">"don't be verbose" ➜ say the target instead: "3 sentences max"</span>

<span class="bad">✘</span> **20 tools in one agent**
<span class="muted">selection accuracy falls off a cliff; split the agent</span>

<span class="bad">✘</span> **Testing on one example**
<span class="muted">it works on your example. That is what "overfit" means</span>

<span class="bad">✘</span> **Fixing prompts by adding**
<span class="muted">deleting the conflicting line usually beats adding a new one</span>

<!-- reset_layout -->

<!-- end_slide -->

<!-- jump_to_middle -->

<span class="kicker">/// PART 04</span>

TOOL CALLING + STRUCTURED OUTPUTS
===

<!-- end_slide -->

<span class="kicker">/// THE LIFECYCLE</span>

FOUR STEPS, AND YOU OWN THREE
===

```text
  1. DECLARE     you send tool schemas alongside the prompt
                 ─────────────────────────────────────────────────────────
  2. REQUEST     model replies stop_reason="tool_use" + name + JSON args
                 (it did NOT run anything — it asked)
                 ─────────────────────────────────────────────────────────
  3. EXECUTE     YOUR code validates the args and runs the function
                 (permissions, allow-lists, confirmation prompts live here)
                 ─────────────────────────────────────────────────────────
  4. RETURN      you append a tool_result and call the model again
                 ─────────────────────────────────────────────────────────
                 model either asks for another tool, or answers
```

<!-- pause -->

<!-- new_line -->

> Steps 1, 3 and 4 are **your ordinary code.** The model only does step 2. Every time someone says "the agent deleted my database," they mean **their step 3 had no guardrail.**

<!-- end_slide -->

<span class="kicker">/// DESIGN</span>

WHAT MAKES A GOOD TOOL
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

<span class="bad">**✘ BAD TOOL**</span>

```python
{
  "name": "db",
  "description": "Query the database.",
  "input_schema": {
    "properties": {
      "q": {"type": "string"}
    }
  }
}
```

<span class="muted">Unbounded. The model writes raw SQL, you run it. Name says nothing. One typo is a table scan — or a `DROP`.</span>

<!-- column: 1 -->

<span class="good">**✔ GOOD TOOL**</span>

```python
{
  "name": "find_orders_by_customer",
  "description": (
    "Look up a customer's orders from the "
    "last 90 days. Returns up to 20, newest "
    "first, with id, status and total. Use "
    "when the user names a specific customer. "
    "Does NOT cover refunds or shipping."
  ),
  "input_schema": {
    "properties": {
      "customer_id": {"type": "string"},
      "status": {"enum": ["open","shipped","all"]}
    },
    "required": ["customer_id"]
  }
}
```

<!-- reset_layout -->

<!-- pause -->

> **Design tools for the model, not for your ORM.** Narrow verb-shaped names, enums instead of free strings, bounded results, and a description that says when *not* to use it.

<!-- end_slide -->

<span class="kicker">/// DESIGN</span>

HOW MANY, AND HOW BIG
===

<!-- column_layout: [1, 1, 1] -->

<!-- column: 0 -->

<span class="accent">**COUNT**</span>

**5–10 is the sweet spot.**

<span class="muted">Past ~15, selection accuracy falls off hard and every schema is also tokens you pay for on every single turn. Too many tools? Split into two agents, or add a router.</span>

<!-- column: 1 -->

<span class="accent">**GRANULARITY**</span>

**One tool per user intent.**

<span class="muted">Not one per endpoint. `book_appointment` beats `check_slots` + `hold_slot` + `confirm` — three tools is three chances to stop halfway.</span>

<!-- column: 2 -->

<span class="accent">**PARALLELISM**</span>

**One turn can request several.**

<span class="muted">Independent lookups come back in a single `tool_use` block. Execute them concurrently and return all results together — one round trip, not three.</span>

<!-- reset_layout -->

<!-- pause -->

<!-- new_line -->

> Overlapping tools are worse than missing ones. If two tools could plausibly answer the same question, the model will flip between them — and you will call it "flaky."

<!-- end_slide -->

<span class="kicker">/// FAILURE HANDLING</span>

WHAT TO RETURN WHEN A TOOL FAILS
===

<span class="muted">The tool result is not a log line — it is **the next thing the model reads.** Write it for the model.</span>

<!-- new_line -->

| The tool hit | <span class="bad">✘ Don't return</span> | <span class="good">✔ Do return</span> |
|---|---|---|
| No rows | `[]` | `"No orders found for CUST-91 in the last 90 days."` |
| Bad argument | 500 / stack trace | `"Error - status must be one of open, shipped, all."` |
| Auth failure | `null` | `"Error - not permitted. Ask the user to authenticate."` |
| Timeout | hang | `"Error - timed out after 10s. Safe to retry once."` |
| Huge result | 40KB of JSON | first 20 rows + `"...812 more. Narrow the filter."` |

<!-- pause -->

<!-- new_line -->

> An empty result and a broken tool look **identical** to the model, so it fills the gap with something plausible. Say what went wrong and whether retrying helps — then it can actually recover.

<!-- end_slide -->

<span class="kicker">/// STRUCTURED OUTPUTS</span>

FOUR WAYS TO GET JSON, RANKED
===

| | Approach | Guarantee |
|---|---|---|
| **L1** | Ask for JSON in the prompt | None. Prose, fences, apologies |
| **L2** | Ask + give the exact schema + one example | Better. Still fails under load |
| **L3** | Prefill the assistant turn with `{` | It cannot open with prose |
| **L4** | **Schema-constrained decoding** — structured output / tool-schema mode | **Invalid JSON is unrepresentable** |

<!-- pause -->

<!-- new_line -->

<span class="muted">L4 is not better prompting — it is a different mechanism. The decoder masks every token that would break the schema, so malformed output is not unlikely, it is **impossible.**</span>

<!-- new_line -->

> If a program parses it, use L4. Keep L2 as a habit anyway — a clear schema in the prompt still improves the *content*, not just the shape.

<!-- end_slide -->

<span class="kicker">/// STRUCTURED OUTPUTS</span>

IN PRACTICE
===

<span class="muted">Define the shape once, in code, and let it generate the schema. Never hand-write JSON schema twice.</span>

```python
from pydantic import BaseModel
from typing import Literal

class BugReport(BaseModel):
    summary: str
    feature: str
    severity: Literal["high", "medium", "low"]   # enum, not free text
    reproducible: bool

class Triage(BaseModel):
    bugs: list[BugReport]                        # a LIST is a top-level object field,
    reviewed_count: int                          # because most APIs require an object root

# schema = Triage.model_json_schema()  ->  pass as the response format / tool schema
# result = Triage.model_validate_json(reply.text)   <- typed object, not a dict
```

<!-- pause -->

<!-- new_line -->

> Constrained decoding guarantees the **shape**, never the **truth.** `severity` will always be one of your three values; whether it is the *right* one is what evals are for (Oct 26).

<!-- end_slide -->

<span class="kicker">/// THE PUNCHLINE</span>

TOOL CALLING *IS* STRUCTURED OUTPUT
===

<span class="muted">They look like two features. Underneath they are one mechanism pointed in two directions.</span>

<!-- new_line -->

```text
                       ┌──────────────────────────────┐
                       │  schema-constrained decoding │
                       └──────────────┬───────────────┘
                       ┌──────────────┴───────────────┐
                       ▼                              ▼
              TOOL CALL                       STRUCTURED OUTPUT
      "emit args matching this            "emit an answer matching
       schema, I will run it"              this schema, I will parse it"
                       │                              │
                  side effect                     typed data
```

<!-- pause -->

<!-- new_line -->

> Which is why the fix for "it returned garbage JSON" and the fix for "it called the tool wrong" are **the same fix**: tighten the schema and sharpen the description.

<!-- end_slide -->

<!-- jump_to_middle -->

<span class="kicker">/// PART 05</span>

DEMO: 40 LINES
===

<!-- end_slide -->

<span class="kicker">/// NO FRAMEWORK REQUIRED</span>

THE WHOLE AGENT
===

<span class="muted">This is the real structure. LangChain, LangGraph, the Agents SDK — all of them are this, with retries and telemetry bolted on.</span>

```python
def run_agent(goal, tools, max_turns=10):
    messages = [{"role": "user", "content": goal}]

    for turn in range(max_turns):                  # 05 · harness: hard cap
        reply = model.call(                        # 01 · model
            system=SYSTEM_PROMPT,                  # 02 · instructions
            messages=messages,                     # 04 · memory
            tools=[t.schema for t in tools],       # 03 · tools
        )
        messages.append(reply)

        if reply.stop_reason != "tool_use":        # model decided it is done
            return reply.text

        for call in reply.tool_calls:              # ACT
            result = tools[call.name](**call.args)
            messages.append(tool_result(call.id, result))   # OBSERVE

    return "Hit turn limit without an answer."     # fail loud, not silent
```

<!-- pause -->

<span class="muted">Twelve real lines. Every one of the five parts is labeled. There is nothing else hiding.</span>

<!-- end_slide -->

<span class="kicker">/// LIVE</span>

WATCH THE LOOP SPIN
===

<span class="muted">Real loop, fake model — a stub that returns scripted tool calls, so the mechanics are visible with no API key and no network. Press `Ctrl-E` to run.</span>

```python +exec
import sys; sys.path.insert(0, "demo")
from mini_agent import run_agent
run_agent("What was the high in Champaign yesterday, in Celsius?")
```

<!-- speaker_note: If exec is not enabled you will see a "not started" status. Launch with scripts/present.sh 01, which passes -x. Fallback is running `python demo/mini_agent.py` in a second terminal. -->

<!-- end_slide -->

<span class="kicker">/// DEBRIEF</span>

WHAT YOU JUST SAW
===

<!-- new_line -->

**1.** The harness never decided anything. It only **executed and appended**.

**2.** The model made three decisions: <span class="muted">which tool, what arguments, when to stop.</span>

**3.** The conversation **grew every turn** — that is the cost curve, and that is context rot in miniature.

**4.** A `max_turns` cap was the only thing standing between you and an infinite loop.

<!-- pause -->

<!-- new_lines: 2 -->

> Swap the fake model for a real API call and the tools for real functions, and you have shipped an agent. **Everything after tonight is making that loop reliable.**

<!-- end_slide -->

<!-- jump_to_middle -->

<span class="kicker">/// PART 06</span>

WHAT'S NEXT
===

<!-- end_slide -->

<span class="kicker">/// RECAP</span>

THE EIGHT THINGS
===

<!-- new_line -->

<span class="accent">**01**</span>  An LLM is a next-token function that **samples**. Same input, different output — by design.

<span class="accent">**02**</span>  **Tokens are the unit of everything.** Cost, context limits, and half the model's quirks.

<span class="accent">**03**</span>  Agent = **model + tools + loop.** The model owns control flow; that is the whole definition.

<span class="accent">**04**</span>  **Workflow first.** Climb to an agent only when the tier below actually fails.

<span class="accent">**05**</span>  Five parts: model · instructions · **tools** · memory · **harness**. The bold two decide whether it works.

<span class="accent">**06**</span>  A prompt is a program: **be specific, show examples, leave room to think, constrain output, give it an exit.**

<span class="accent">**07**</span>  **The model never runs anything — it asks.** Your step 3 is where every guardrail lives.

<span class="accent">**08**</span>  Tool calling and structured outputs are **one mechanism**: schema-constrained decoding. Tighten the schema, sharpen the description.

<!-- end_slide -->

<span class="kicker">/// BEFORE THURSDAY</span>

HOMEWORK
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->

<span class="badge"> DO </span>

**1. Install Claude Code.** <span class="muted">Thursday is laptop-open. Show up ready.</span>

**2. Find the workflow.** <span class="muted">Pick a repetitive task you actually do. Write the steps out by hand. Bring it Thursday — that is your build target.</span>

**3. Break a prompt on purpose.** <span class="muted">Write a vague prompt, run it 5 times, watch the outputs diverge. Then fix it with Rule 01.</span>

**4. Write one tool schema.** <span class="muted">For the workflow in #2, write the description a model would need. It is harder than it looks.</span>

<!-- column: 1 -->

<span class="badge"> READ </span>

<span class="muted">— Anthropic, **Building Effective Agents** <span class="dim">(the workflow/agent split, from the source)</span></span>

<span class="muted">— **ReAct: Synergizing Reasoning and Acting in Language Models** <span class="dim">(Yao et al., 2022 — short, readable)</span></span>

<span class="muted">— Anthropic docs — **Tool use** and **structured outputs** <span class="dim">(the reference for Part 04)</span></span>

<!-- reset_layout -->

<!-- new_line -->

> Thursday Sep 10 · **Business Workflow Automation 101** — you will build the thing you scoped in homework #2.

<!-- end_slide -->

<span class="kicker">/// THE ROAD AHEAD</span>

WHERE THIS GOES
===

| Upcoming lecture | What it unlocks |
|---|---|
| **RAG + advanced RAG** <span class="accent">— next week</span> | Agents that know *your* data |
| Memory — short, long, hybrid | Agents that persist across sessions |
| Multi-agent architectures | Splitting work across specialists |
| Context + harness engineering | The fix for context rot |
| Graph + loop engineering | Iterative execution you can reason about |
| Eval systems for agents | Knowing it works before users do |

<span class="muted">Then post-training and distillation · preference optimization, GRPO and RL · voice agents — ending **Dec 07** with the Final Project Studio + Demo Night.</span>

<!-- end_slide -->

<span class="kicker">/// MODULE 01 COMPLETE</span>

QUESTIONS?
===

<span class="muted">Then stick around — the fastest way to learn this is to start building tonight.</span>

<!-- new_lines: 2 -->

<span class="badge"> AGENTICAIUIUC.COM </span>   <span class="dim">·</span>   <span class="muted">Thursday Sep 10 · Workshop 01 · bring a laptop</span>
