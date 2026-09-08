"""Minimal ReAct agent loop for the Module 01 lecture.

Deliberately dependency-free and offline: `FakeModel` returns a scripted
sequence of tool calls instead of hitting an API. The *loop* is real -- swap
FakeModel for an actual client and this is a working agent.

Run standalone:  python demo/mini_agent.py
"""

import json
import time

# --- 03 · TOOLS ------------------------------------------------------------
# A tool is a schema the model reads plus a function the harness runs.


def get_date(offset_days=0):
    # Fixed date so the lecture demo is reproducible.
    return "2026-09-07" if offset_days == -1 else "2026-09-08"


def get_weather(city, date):
    return {"city": city, "date": date, "high_f": 81, "low_f": 63}


TOOLS = {"get_date": get_date, "get_weather": get_weather}


# --- 01 · MODEL (stubbed) --------------------------------------------------
# Scripted so the loop is visible without a network call or an API key.


class Reply:
    def __init__(self, stop_reason, thought, tool=None, args=None, text=None):
        self.stop_reason = stop_reason
        self.thought = thought
        self.tool = tool
        self.args = args
        self.text = text


class FakeModel:
    SCRIPT = [
        Reply("tool_use", "I need yesterday's date before I can look up weather.",
              tool="get_date", args={"offset_days": -1}),
        Reply("tool_use", "Now fetch the recorded high for that date.",
              tool="get_weather", args={"city": "Champaign, IL", "date": "2026-09-07"}),
        Reply("end_turn", "81F -> (81-32)*5/9 = 27.2C. I have the answer. Stop.",
              text="Yesterday's high in Champaign was 81F (27.2C)."),
    ]

    def call(self, system, messages, tools):
        # A real client would send `messages` over HTTP here. The important
        # detail for the lecture: the ENTIRE transcript is resent every turn.
        turn = sum(1 for m in messages if m["role"] == "tool_result")
        return self.SCRIPT[min(turn, len(self.SCRIPT) - 1)]


# --- 05 · HARNESS ----------------------------------------------------------

SYSTEM_PROMPT = "You are a weather assistant. Use tools; never guess a date."

ORANGE, GRAY, GREEN, RESET = "\033[38;2;242;92;20m", "\033[38;2;154;154;154m", "\033[38;2;111;207;112m", "\033[0m"


def _say(label, body, color=GRAY, pause=0.45):
    print(f"  {color}{label:<9}{RESET} {body}", flush=True)
    time.sleep(pause)


def run_agent(goal, model=None, max_turns=10):
    model = model or FakeModel()
    messages = [{"role": "user", "content": goal}]

    _say("USER", goal, ORANGE)
    print(flush=True)

    for turn in range(max_turns):  # the cap that prevents an infinite loop
        reply = model.call(SYSTEM_PROMPT, messages, list(TOOLS))
        messages.append({"role": "assistant", "content": reply.thought})
        _say("THOUGHT", reply.thought)

        if reply.stop_reason != "tool_use":  # the model decided it was done
            _say("ANSWER", reply.text, GREEN)
            print(f"\n  {GRAY}{turn + 1} turns · {len(messages)} messages in context{RESET}", flush=True)
            return reply.text

        # ACT: the model asked; the harness decides whether to comply.
        _say("ACTION", f"{reply.tool}({json.dumps(reply.args)})", ORANGE)
        result = TOOLS[reply.tool](**reply.args)

        # OBSERVE: the result is appended and resent on the next turn.
        messages.append({"role": "tool_result", "content": json.dumps(result)})
        _say("OBSERVE", json.dumps(result))
        print(flush=True)

    return "Hit turn limit without an answer."  # fail loud, never silently


if __name__ == "__main__":
    run_agent("What was the high in Champaign yesterday, in Celsius?")

    # Smallest check that the loop itself is correct: it must terminate via
    # the model's stop_reason, not by exhausting max_turns.
    assert "27.2C" in run_agent("recheck", model=FakeModel())
    assert run_agent("x", model=FakeModel(), max_turns=1).startswith("Hit turn limit")
    print(f"\n  {GREEN}self-check ok{RESET}")
