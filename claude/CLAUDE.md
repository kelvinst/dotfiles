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

## Asking questions

- Put links in an `AskUserQuestion` as normal markdown. Mobile (Remote Control,
  the claude.ai app) renders the link text and drops the href, so the
  `askuserquestion-links` PreToolUse hook rewrites `[text](url)` to `text: url`
  in the question and in every option description before the question is shown
  — no need to repeat the link in the reply for that reason alone.
