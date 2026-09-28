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
replies, AskUserQuestion questions and option labels, and every commit you
write.

## Repo type

Detect it from the repository root (`git rev-parse --show-toplevel`), the same
way `preflight` does. The first match wins:

1. **Kingdone** — `Gates/Gates.md` exists. The vault's own conventions (its
   `CLAUDE.md`) apply: the `Urgency:` trailer, renames through the Obsidian
   CLI, and so on.
2. **Beads** — a `.beads/` directory exists and `command -v bd` succeeds.
3. **Neither** — no tracker.

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
bookkeeping of step 2 (marking the shipped task done on the user's yes) and the
archive.

Run the `ship` skill. It runs `preflight` (rebase, the five checks, findings,
fixes and deferrals), asks the user to confirm, and pushes. If it stops — a
**changed** or **open** verdict, a "Not yet", a failed push — report why and
stop: the session is not ready to archive.

## 2. Archive

Tell the user what was done: fixes with their commits, what was deferred, what
was left or discarded (each discard with its reason), what was inferred and
from where. Every arrival you mention is a link to its note; every bd task and
every closed issue is named by its id.

Everything below runs **only after a successful ship**, in this order.

**a. Mark the task done.** Find the task the session was about, the same way
the Create task job finds the current work: an id in the branch name, the task
claimed or worked on in this session, or one the conversation names. If none is
identifiable, say so and ask nothing. Otherwise ask with AskUserQuestion,
naming each task: "Mark <task> done" (Recommended) — "Its work is now on
`<default>`." · "Leave it open". Never mark a task done without that yes.

- _(Beads)_ The task is a bd issue. On yes:
  `bd close <id> --reason="shipped to <default>"`, then `bd dolt push` when the
  repo has a Dolt remote.
- _(Kingdone)_ The task is a quest (`qst-<id> <title>`, a note or a folder), in
  progress in `Satchel/Quest Pocket/` or planned in
  `Observatory/Drawer/Quests/Planned/`. On yes: stamp its note's frontmatter
  with `completed: YYYY-MM-DD` (today) — for a note quest, that note; for a
  folder quest, its main note, the one named after the quest's subject without
  the `qst-<id>` prefix or verb, which the supporting notes are named after
  (e.g. `Kix Checkpoints.md`; when unclear, ask the user which) — move it (a
  folder quest moves whole) to `Observatory/Drawer/Quests/Completed/` through
  the Obsidian CLI so links follow, commit
  (`docs(observatory): <qst-id> is completed`, `Urgency: fyi`), and push it
  straight to `<default>` as a fast-forward (`git push origin HEAD:<default>`,
  then the branch). This status-only commit is the one commit allowed after the
  ship.
- _(Neither)_ No tracker: skip this.

**b. Archive.** Ask with AskUserQuestion: "Archive this session now?" —
"Archive" (Recommended) · "Leave it open". On "Archive", get this session's
state with `mcp__ccd_session_mgmt__get_session` (`"self"`), then, before
archiving:

- **Remote Control.** When `remoteControlState` is `on` or `connecting`, turn
  it off with `mcp__ccd_session_mgmt__set_remote_control`
  (`session_id: "self"`, `enabled: false`) — the app asks the user to approve —
  so no phone or claude.ai link stays open on an archived session. When
  `startedViaRemoteControl` is true the switch is locked: say so and go on.
- **Pin.** When `pinned` is true, unpin it with `mcp__ccd_sidebar__set_pinned`
  (`session_id: "self"`, `pinned: false`), so the sidebar's Pinned list only
  holds live work.

Then call `mcp__ccd_session_mgmt__archive_session` with `session_id: "self"`.
Never archive without that answer, or while the work is not in `<base>`.

## Common mistakes

- Reviewing, rebasing or resolving findings from close itself instead of
  through `ship` → `preflight`.
- Doing any work after the ship.
- Marking a bd issue or a quest done without asking, or before the ship.
- Archiving after a ship that stopped.
- Archiving with Remote Control still on, or the session still pinned.
- Hardcoding `main` instead of the detected default branch.
- Naming an arrival without linking it, or a task without its id.
- Writing in English to a user who speaks Portuguese.
