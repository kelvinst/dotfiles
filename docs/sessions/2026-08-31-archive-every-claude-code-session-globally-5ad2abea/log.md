---
saved_at: 2026-08-31T18:31:33Z
session_id: 5ad2abea-3d39-4ad0-8fe0-9a820b326fe3
transcript: transcript.jsonl.gz
---

# Archive every Claude Code session globally without opening a PR

> **Source:**
> `~/.claude/projects/-Users-kelvinstinghen-Developer-worktrees-dotfiles-confident-mccarthy-0f1cd5/5ad2abea-3d39-4ad0-8fe0-9a820b326fe3.jsonl`
> (local; not a public link).

## Goal

Make every Claude Code session archive its own reasoning automatically, in
every project rather than just this one, and without opening a pull request
for the archive.

_Update sections below were written with `caveman:caveman` compression active._

## 2026-08-31 — update (wiring save-session into every session)

- Question: can `/save-session` run after all CC sessions, no PR?
- Chain already existed. Stop hook `claude/hooks/autocommit.sh` → instructs
  `/kix:commit` → `kix:commit` Step 1 invokes `/kix:save-session --no-commit`
  → archive staged into the same commit. `--no-commit` never reaches the
  skill's standalone branch+PR path, so no PR. No `kix-agents` change needed.
- Alternative: add a `--no-pr` flag to `kix:save-session`. Rejected —
  `--no-commit` already guarantees no PR; a second flag would be redundant.
- Alternative: use a `SessionEnd` hook for true per-session timing. Rejected —
  `SessionEnd` output is not fed back to the model, so it cannot invoke a
  skill. `Stop` (per-turn) is the only hook that can.
- Root gap found: `kix@kix-agents` was enabled at **project scope only**, for
  `/Users/kelvinstinghen/Developer/Stingdom`
  (`~/.claude/plugins/installed_plugins.json`). Everywhere else the Stop hook
  fell through to fallback `caveman:caveman-commit`, which archives nothing.
- Fix: added `"kix@kix-agents": true` to `enabledPlugins` in
  `claude/settings.json`, copied to `~/.claude/settings.json`. Commit
  `4c3d75a`. Beads `dot-6gw`.
- Flagged to user: enabling this globally commits verbatim
  `docs/sessions/<stem>/transcript.jsonl.gz` into **every** repo opened —
  including repos he does not own. The transcript holds every tool result and
  any environment values that passed through the session. Offered to gate it
  (allowlist, or skip when `origin` is not his); left undecided.

## 2026-08-31 — update (covering turns that changed no code)

- User: discussion-only sessions must be saved too.
- Old `autocommit.sh` exited 0 when the tree was clean, or dirty only in
  `.beads/issues.jsonl` — so a turn that produced reasoning but no edits left
  no trace at all.
- Rewrote `claude/hooks/autocommit.sh`. Guards unchanged (`stop_hook_active`,
  inside-worktree, mid rebase/merge/cherry-pick/revert/bisect). Then two modes
  via `HOOK_MODE`:
  - `code` (real changes present) → existing `/kix:commit` reason, which
    bundles the archive into the code commit.
  - `archive` (clean, or beads churn only) → run `kix:save-session
    --no-commit`, `git add` any `.beads/` churn, then commit exactly those
    paths as `docs: save session - <title>` (`docs: update saved session -
    <title>` on a re-save).
- Reason text names `kix:save-session` explicitly and warns off
  `anthropic-skills:save-session`, which *does* open a PR.
- Alternative: route to `/kix:commit` even on a clean tree. `kix:commit` would
  stage nothing from code, save-session's archive would become the whole diff,
  and the generated message would end up describing the archive. Rejected —
  the fixed `docs: save session` message is honest and skips message
  generation entirely.
- Verified all four branches by feeding the hook JSON on stdin: clean →
  archive, dirty → code, tracked `.beads/issues.jsonl` churn → archive,
  `stop_hook_active: true` → exit 0 with no output (no loop).
- Commit `d0a8716`. Beads `dot-zml`.
- Known quirk left alone: an *untracked* `.beads/` directory collapses to
  `?? .beads/` in `git status --porcelain`, so it reads as `code` mode.
  Pre-existing behaviour; only bites a repo where beads was never committed.
- Consequence stated to user: `Stop` fires per turn, not per session, so every
  turn in every repo now ends in a commit — one-line Q&A included. A long
  session yields a string of `docs: update saved session` commits.

## Open Questions

- [x] Can the session archive be saved without opening a PR?
  - Yes — `--no-commit` stages only, and never reaches the skill's standalone
    branch+PR path.
- [x] Is there a hook that fires at true session end and can invoke a skill?
  - No. `SessionEnd` output is not returned to the model. `Stop` (per-turn) is
    the only workable trigger.
- [ ] Should archiving be gated to repos kelvin owns (allowlist, or an
      `origin` check in `kix:save-session` Step 1)? Raised, not decided.
- [ ] Is a commit per turn acceptable long-term, or should the archive commit
      be squashed/deferred somehow?

## Action Items

- [x] Enable `kix@kix-agents` globally — beads `dot-6gw`, commit `4c3d75a`
- [x] Archive clean-tree turns — beads `dot-zml`, commit `d0a8716`
- [ ] Restart Claude Code so `kix@kix-agents` installs at user scope
- [ ] Decide on per-repo gating (would be a `kix-agents`
      `save-session` Step 1 change)
