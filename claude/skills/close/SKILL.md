---
name: close
description:
  Use when the user types /close, or says they want to close, finish, wrap up
  or archive the current Claude session ("fechar a sessão", "encerrar", "posso
  arquivar?").
---

# Close the session

The user opens more sessions than they close. `/close` answers one question —
**can this session be archived without losing anything?** Only a session whose
work is on the default branch gets archived. The checks themselves live in the
`preflight` skill, which `ship` runs; close adds only what comes after the
ship.

**Language.** Everything you produce follows the language the user is speaking:
replies, AskUserQuestion questions and option labels.

**Default branch.** Never assume `main`:

```bash
git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null \
  || { git remote set-head origin --auto >/dev/null && git symbolic-ref --short refs/remotes/origin/HEAD; }
```

Below, `<base>` is that ref (e.g. `origin/main`) and `<default>` is the branch
name without `origin/`.

## 1. Ship

Shipping is always the **last** thing a session does: nothing — no fix, no
arrival, no task, no other work — runs after it. The only exceptions are the
tracker bookkeeping and the archive of step 2.

Run the `ship` skill. It runs `preflight` (rebase, code review, conversation
and checklist checks, findings, fixes and deferrals), asks the user to confirm,
and pushes. If it stops — a **changed** or **open** verdict, a "Not yet", a
failed push — report why and stop: the session is not ready to archive.

## 2. Archive

Only after a successful ship. Tell the user what was done: fixes with their
commits, what was deferred, what was left or discarded, what was inferred and
from where. Every arrival you mention is a link to its note; every bd task and
every closed issue is named by its id.

_(Beads — a `.beads/` directory exists and `command -v bd` succeeds.)_ Before
the archive question, handle the issue(s) the branch was about: an id in the
branch name, the issue claimed or worked on in this session, or one the
conversation names. If none is identifiable, say so and ask nothing. Otherwise
ask with AskUserQuestion whether to close them, naming each id and title:
"Close <id>" (Recommended) — "Closes the issue as shipped: its work is now on
`<default>`." · "Leave it open". Only on the user's yes, run
`bd close <id> --reason="shipped to <default>"`, then `bd dolt push` when the
repo has a Dolt remote. Never close an issue without that answer.

Then ask with AskUserQuestion: "Archive this session now?" — "Archive"
(Recommended) · "Leave it open". On "Archive", call
`mcp__ccd_session_mgmt__archive_session` with `session_id: "self"`. Never
archive without that answer, or while the work is not in `<base>`.

## Common mistakes

- Reviewing, rebasing or resolving findings from close itself instead of
  through `ship` → `preflight`.
- Doing any work after the ship.
- Closing a bd issue without asking, or before the ship.
- Archiving after a ship that stopped.
- Hardcoding `main` instead of the detected default branch.
- Naming an arrival without linking it, or a task without its id.
- Writing in English to a user who speaks Portuguese.
