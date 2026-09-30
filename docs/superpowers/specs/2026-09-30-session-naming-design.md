# Session naming skill — design

Bead: `dot-mrr`. Related: `dot-4v7` (split ship into land + close), `dot-0oq`
(auto-name sessions on start — overlaps, see Open questions).

## Goal

Glance at the Claude sidebar and know, per session: which project, which
tracker item, and where that item is in its lifecycle. The title carries a
prefix with all three; the rest of the title stays a human description.

## Title shape

```
<emoji> <code>-<id> │ <description>
```

- `📝 dot-mrr │ Session naming skill`
- No tracker item yet: `📥 dot │ Session naming skill`
- No tracker at all (repo without Beads or Kingdone): `🔨 xyz │ <description>`

`<code>` is the 3-letter project code. `<id>` is the tracker item's short
base36 id with the tracker prefix dropped: Beads `dot-mrr` → `mrr`, Kingdone
`qst-abc` → `abc`. Child ids keep their suffix (`dot-s52.3` → `s52.3`).

`<description>` is the main item's title, trimmed to about 40 characters on a
word boundary. With no item, a short topic of the session. On a rename the
skill replaces only the prefix (everything before `│`) when the current title
already has one and its description still fits the main item; otherwise it
rewrites the whole title.

## States

| State               | Emoji | Set when                                                                        |
| ------------------- | ----- | ------------------------------------------------------------------------------- |
| registering         | 📥    | the session only files or edits tracker items                                   |
| planning            | 📝    | brainstorming, spec or plan work, no product code edited                        |
| implementing        | 🔨    | code edits or plan execution                                                    |
| reviewing           | 🔍    | preflight starts (also a code review run)                                       |
| landing / landed    | 🛬    | land starts; stays until code edits resume, then 🔨                             |
| shipping            | 🚀    | ship starts                                                                     |
| shipped             | ✅    | close runs with reason `shipped` — only after the work is on the default branch |
| closed, not shipped | 🚫    | close runs with reason cancelled / superseded / wontfix                         |

When guessing from context, the latest signal in the session wins.

## Skill: `/title`

Lives at `claude/skills/title/SKILL.md` (`/rename` is taken by the built-in).
Installed by `make install` like the other skills (the Makefile globs
`claude/skills/*`).

**Arguments.** None → guess every part from the session. Any part can be given
to override the guess, in any order: a state word or emoji (`impl`, `🔍`), a
tracker id (`dot-abc`, `qst-abc`), or free text for the description.

**Steps.**

1. **Project code** (see below).
2. **Tracker** — detected the same way `preflight` and `close` do, first match
   wins: Kingdone (`Gates/Gates.md`), Beads (`.beads/` and `bd` on PATH),
   neither.
3. **Main item** (see below).
4. **State** — argument, else the table above applied to the session.
5. **Description** — argument, else from the main item, else session topic.
6. **Rename** — `mcp__ccd_session_mgmt__set_session_title` (desktop app). When
   that tool is not available (plain CLI), print `/rename <title>` for the user
   to run.
7. **Report** — one line with the new title.

The skill never fails hard: any part it cannot resolve is left out, and the
worst case is a printed proposed title.

## Project code

Stored per repo in the checked-in `.claude/settings.json`:

```json
{ "env": { "PROJECT_CODE": "dot" } }
```

`env` is an official settings key, so no schema warnings, and every worktree
and clone gets the value.

When missing, the code is derived from the **original** repo's folder name, not
the worktree's: the parent of
`git rev-parse --path-format=absolute --git-common-dir`. Proposal rule:
initials of the name's words split on `-`, `_`, `.` or camel case when there
are three or more; otherwise the first letters of the name (`dotfiles` →
`dot`). The proposal is only a starting point — `kix-agents` → `kxa` is a human
choice — which is why the user confirms. The skill shows the proposal, the user
confirms or types another, and the skill writes it into `.claude/settings.json`
on the current branch, creating the file or merging into an existing one. It
then ships with the branch like any other change.

Known codes: `dot` dotfiles, `kxa` kix-agents, `stg` Stingdom, `okc`
obsidian-kingdone-chapel.

The deterministic part — find the repo name, read an existing code, propose one
— is a script, `bin/project-code`, with `test/project-code.sh` run by
`make test`. The skill calls it and handles the confirm and the write.

## Main item

Candidates: tracker items this session created, claimed or edited, plus an id
in the branch name. Resolution, in order:

1. One candidate, or one clearly central → it.
2. **Supersede first.** Several candidates where one covers the others →
   propose closing the rest as superseded by it (Beads:
   `bd supersede <other> --with=<main>`; Kingdone: the vault's own convention).
   Pure duplicates are handled the same way. The survivor is the main item.
3. Remaining candidates share a parent → the parent.
4. Remaining candidates share a topic but no parent → propose a new epic
   (title + children) and reparent them under it; the epic is the main item.
5. Unrelated → ask which one is main.

Steps 2 and 4 write to the tracker and wait for the user's yes. Steps 1, 3 and
5 are silent or a plain question.

## Hooks into other skills

The skill is driven by invocations, not by a hook. Called by another skill it
never asks and never writes: no project code → left out, several items → best
silent guess, no supersede or epic proposal. Each lifecycle skill runs `/title`
with its state as its first step (and ✅/🚫 at the end of close):

| Skill     | Title call                                  |
| --------- | ------------------------------------------- |
| preflight | `/title 🔍` at start                        |
| land      | `/title 🛬` at start                        |
| ship      | `/title 🚀` once preflight comes back clear |
| close     | `/title ✅` when reason is shipped, else 🚫 |

`dot-4v7` renames and splits these skills. At implementation time the lines go
into whichever of the four exist. If `dot-4v7` has not landed yet, today's
`preflight`, `ship` and `close` get 🔍, 🚀 and ✅ (close only archives shipped
work today), and a line is added to `dot-4v7` to add the 🛬 and 🚫 hooks.

For states no owned skill marks (📥, 📝, 🔨 — brainstorming and plan execution
come from plugins), a line in the global `claude/CLAUDE.md` tells the agent to
run `/title` when the session's state changes: an item gets filed, a design or
plan gets approved, implementation starts.

## Testing

- `test/project-code.sh`: repo name from a worktree resolves to the original
  repo; existing `PROJECT_CODE` is returned as is; proposals for sample names.
- Manual, in the desktop app: `/title` in this session gives
  `📝 dot-mrr │ Session naming skill`; `/title impl` switches to 🔨; a repo
  with no code asks for one and writes `.claude/settings.json`; plain CLI
  prints a `/rename` line.

## Open questions

- `dot-0oq` (auto-name sessions on start) overlaps this. Proposal: close it as
  superseded by `dot-mrr`, optionally adding a SessionStart nudge that asks the
  agent to run `/title` on the first turn.
