# Global instructions

## Response style

- Every reply uses caveman mode at the active level (default: ultra) — no
  matter where the reply comes from: after a skill, a long tool output, a
  subagent report, or deep in a long session. Skill output formats (a findings
  list, an AskUserQuestion) keep their structure, but their prose is caveman
  too.
- Normal prose only for code, commit messages, PR bodies, security warnings and
  confirmations of irreversible actions.
- No explanations unless asked. Give the result, not the reasoning behind it;
  the user asks explicitly when they want the why.

## Session title

- Run the `kix:title` skill whenever the session's state changes: a tracker
  item gets filed, a design or plan gets approved, the item's work starts (code
  in a code repo, the deliverable notes, research or documents in a notes
  repo). The `kix:close` skill runs it itself for 📦 and 🏁.

## Asking questions

- Every AskUserQuestion, from any skill or a plain reply, goes out in this
  order:
  1. the text the user needs to answer it — a finding block, the options
     explained, links — in the reply;
  2. a real command of its own (a `grep`, a `bd show`, a `git` call that the
     question is about);
  3. the ❓ line, when the skill uses progress lines;
  4. the AskUserQuestion call.
- The app summarizes the reply text that comes right before a question card,
  and on mobile the user then gets a one-line summary instead of the block. A
  tool call between the text and the card keeps the text whole.
- Links never go inside the question card: a link in a card cannot be opened on
  mobile.
