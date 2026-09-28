#!/bin/bash
# PreToolUse hook for AskUserQuestion: flatten markdown links in the question
# payload. Mobile (Remote Control, the claude.ai app) renders the link text
# but drops the href, so `[compare](https://...)` reaches the phone as a dead
# word. Rewriting it to `compare: https://...` through updatedInput puts the
# URL itself on screen, where it can be tapped or copied.
#
# Question text and option descriptions get `text: url`. Option labels are
# buttons - they keep the text and lose the URL, which would not fit anyway.

/usr/bin/python3 -c '
import json, re, sys

LINK = re.compile(r"\[([^\]]*)\]\(\s*<?(https?://[^\s<>)]+)>?\s*\)")

def expand(s):
    return LINK.sub(lambda m: "%s: %s" % (m.group(1).strip(), m.group(2)), s)

def strip(s):
    return LINK.sub(lambda m: m.group(1).strip(), s)

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool_input = data.get("tool_input") or {}
questions = tool_input.get("questions")
if not isinstance(questions, list):
    sys.exit(0)

changed = False

def rewrite(holder, key, fn):
    global changed
    old = holder.get(key)
    if not isinstance(old, str):
        return
    new = fn(old)
    if new != old:
        holder[key] = new
        changed = True

for question in questions:
    if not isinstance(question, dict):
        continue
    rewrite(question, "question", expand)
    options = question.get("options")
    if not isinstance(options, list):
        continue
    for option in options:
        if not isinstance(option, dict):
            continue
        rewrite(option, "label", strip)
        rewrite(option, "description", expand)

if not changed:
    sys.exit(0)

print(json.dumps({"hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "updatedInput": tool_input,
}}))
'
