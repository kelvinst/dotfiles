# Session Naming Implementation Plan

> **Executed 2026-09-30; superseded in parts.** After this plan ran, the title
> lost its brackets (`📐 dot-mrr │ <description>`), the states became 📥 📐 🏭
> 🔍 🛬 📦 🏁, and `project-code` generates a code instead of asking for one.
> The spec, `docs/superpowers/specs/2026-09-30-session-naming-design.md`, is
> the current design.

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** A `/title` skill that prefixes the Claude session title with
`[<emoji> <code>-<id>]` — state, project code, main tracker item.

**Architecture:** A tested bash script (`bin/project-code`) owns the
deterministic part: finding the original repo name, reading, proposing and
writing the project code in `.claude/settings.json`. The `title` skill
(Markdown instructions) owns the judgment: main item, state, description, and
the rename call. `preflight`, `ship` and `close` invoke `/title` at their
lifecycle moments; a global `CLAUDE.md` line covers the rest.

**Tech Stack:** bash, git, jq, Claude Code skills (`SKILL.md`), bd.

**Spec:** `docs/superpowers/specs/2026-09-30-session-naming-design.md`

## Global Constraints

- Title shape: `[<emoji> <code>-<id>] <description>`; no item →
  `[<emoji> <code>] <description>`.
- Emojis: 📥 registering, 📝 planning, 🔨 implementing, 🔍 reviewing, 🛬
  landing/landed, 🚀 shipping, ✅ shipped, 🚫 closed not shipped.
- ✅ only after the work is on the default branch.
- Project code: 3 characters `[a-z0-9]`, stored as `env.PROJECT_CODE` in the
  repo's checked-in `.claude/settings.json`.
- Repo name comes from the original repo (parent of
  `git rev-parse --path-format=absolute --git-common-dir`), never the worktree
  folder.
- Tracker writes (supersede, new epic) wait for the user's yes.
- Markdown formatted with prettier (`printWidth: 79`, `proseWrap: always`).
- Commits: Conventional Commits with a scope (`feat(claude): ...`,
  `feat(bin): ...`), ending with
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Use `cp -f` / `rm -rf` / `mv -f` (aliases may prompt).

## Review Focus

1. `set` on a `.claude/settings.json` that already has hooks/plugins — every
   other key must survive (this repo's own file has `hooks` and
   `enabledPlugins`).
2. Running from a linked worktree **subdirectory** — repo name is still the
   original repo's folder, and `set` writes to the worktree root, not the
   subdirectory.
3. Repo with no `.claude/` directory at all — `get` exits 2 cleanly (no jq
   error on stderr), `set` creates the directory and file.
4. Mixed-case or CamelCase repo names (`Stingdom`, `StingDom`) — proposal is
   lowercase.
5. Invalid code passed to `set` (`DOT`, `dots`, `d-t`) — rejected with exit 1,
   file untouched.

---

### Task 1: `bin/project-code` script

**Files:**

- Create: `bin/project-code`
- Test: `test/project-code.sh`

**Interfaces:**

- Produces (used by Task 2's skill):
  - `project-code` / `project-code get` → prints code, exit 0; no code → prints
    nothing, exit 2; not in a git repo → exit 1.
  - `project-code repo` → prints original repo folder name.
  - `project-code propose` → prints a 3-char proposal.
  - `project-code set <code>` → writes `env.PROJECT_CODE` into
    `<worktree root>/.claude/settings.json`, keeping other keys; invalid code →
    message on stderr, exit 1.

- [x] **Step 1: Write the failing test**

Create `test/project-code.sh` (then `chmod +x test/project-code.sh`):

```bash
#!/usr/bin/env bash
# Tests for `project-code` (dot-mrr).
#
# Every case builds throwaway git repos under a temp dir, so nothing here
# reads or writes a real repo's .claude/settings.json.
set -uo pipefail

PROJECT_CODE_BIN=${PROJECT_CODE_BIN:-"$(cd "$(dirname "$0")/.." && pwd)/bin/project-code"}
failures=0

git_q() { git -c user.name=t -c user.email=t@t "$@" >/dev/null 2>&1; }

# A fresh repo at $work/<name> with one commit; cds into it.
setup() {
  work=$(mktemp -d)
  mkdir -p "$work/$1"
  cd "$work/$1" || exit 1
  git_q init -q
  git_q commit -q --allow-empty -m init
}

teardown() {
  cd / || exit 1
  rm -rf "$work"
}

check() {
  local what=$1 got=$2 want=$3
  if [ "$got" = "$want" ]; then
    echo "  ok: $what"
  else
    echo "  FAIL: $what — got [$got], want [$want]"
    failures=$((failures + 1))
  fi
}

echo "no settings file: get exits 2 quietly"
setup dotfiles
out=$("$PROJECT_CODE_BIN" get 2>&1)
check "exit status" "$?" "2"
check "output" "$out" ""
teardown

echo "get reads an existing code"
setup dotfiles
mkdir -p .claude
printf '{"env":{"PROJECT_CODE":"dot"}}\n' >.claude/settings.json
check "code" "$("$PROJECT_CODE_BIN" get)" "dot"
check "default subcommand is get" "$("$PROJECT_CODE_BIN")" "dot"
teardown

echo "settings without the key: get exits 2"
setup dotfiles
mkdir -p .claude
printf '{"hooks":{}}\n' >.claude/settings.json
"$PROJECT_CODE_BIN" get >/dev/null 2>&1
check "exit status" "$?" "2"
teardown

echo "repo name from a worktree subdirectory is the original repo's"
setup dotfiles
git_q worktree add -q "$work/wt/session-x-123" -b wt
mkdir -p "$work/wt/session-x-123/sub"
cd "$work/wt/session-x-123/sub" || exit 1
check "repo" "$("$PROJECT_CODE_BIN" repo)" "dotfiles"
check "propose" "$("$PROJECT_CODE_BIN" propose)" "dot"
teardown

echo "proposals"
for pair in dotfiles:dot obsidian-kingdone-chapel:okc kix-agents:kix \
  Stingdom:sti StingDomApp:sda my_big.repo-name:mbr; do
  setup "${pair%%:*}"
  check "${pair%%:*}" "$("$PROJECT_CODE_BIN" propose)" "${pair##*:}"
  teardown
done

echo "set creates .claude/settings.json at the worktree root"
setup dotfiles
mkdir -p sub
(cd sub && "$PROJECT_CODE_BIN" set dot)
check "exit status" "$?" "0"
check "written" "$(jq -r .env.PROJECT_CODE .claude/settings.json)" "dot"
check "not in sub" "$([ -e sub/.claude ] && echo yes || echo no)" "no"
teardown

echo "set keeps every other key"
setup dotfiles
mkdir -p .claude
printf '{"hooks":{"SessionStart":[]},"env":{"FOO":"1"}}\n' >.claude/settings.json
"$PROJECT_CODE_BIN" set kxa
check "code" "$(jq -r .env.PROJECT_CODE .claude/settings.json)" "kxa"
check "other env" "$(jq -r .env.FOO .claude/settings.json)" "1"
check "hooks" "$(jq -c .hooks .claude/settings.json)" '{"SessionStart":[]}'
teardown

echo "set rejects invalid codes and leaves the file alone"
setup dotfiles
mkdir -p .claude
printf '{"env":{"PROJECT_CODE":"dot"}}\n' >.claude/settings.json
for bad in DOT dots d-t "" do; do
  "$PROJECT_CODE_BIN" set "$bad" >/dev/null 2>&1
  check "reject [$bad]" "$?" "1"
done
check "untouched" "$(jq -r .env.PROJECT_CODE .claude/settings.json)" "dot"
teardown

echo "outside a git repo: exit 1"
work=$(mktemp -d)
cd "$work" || exit 1
"$PROJECT_CODE_BIN" get >/dev/null 2>&1
check "exit status" "$?" "1"
teardown

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures check(s) failed"
fi
exit $((failures > 0))
```

- [x] **Step 2: Run test to verify it fails**

Run: `./test/project-code.sh` Expected: FAIL lines (script missing — every
check fails), exit 1.

- [x] **Step 3: Write the implementation**

Create `bin/project-code` (then `chmod +x bin/project-code`):

```bash
#!/usr/bin/env bash
# project-code — the repo's 3-letter project code (dot, kxa, okc...), kept in
# the checked-in .claude/settings.json as env.PROJECT_CODE. The /title skill
# puts it in the session title prefix.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: project-code [get|repo|propose|set CODE]

  get        Print the code (default). Exit 2 when the repo has none.
  repo       Print the original repo's folder name — a linked worktree
             resolves to the repo it was made from.
  propose    Print a proposed code derived from the repo name.
  set CODE   Write CODE (3 chars, a-z 0-9) into .claude/settings.json at
             the worktree root, keeping every other key.
EOF
}

# Called as file=$(settings): the exit 1 fails the assignment, and set -e
# ends the script with it.
settings() {
  local top
  top=$(git rev-parse --show-toplevel 2>/dev/null) || exit 1
  echo "$top/.claude/settings.json"
}

cmd_get() {
  local file code
  file=$(settings)
  [ -f "$file" ] || exit 2
  code=$(jq -r '.env.PROJECT_CODE // empty' "$file")
  [ -n "$code" ] || exit 2
  echo "$code"
}

# The common dir is <repo>/.git for the main checkout and every worktree.
cmd_repo() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) ||
    exit 1
  basename "$(dirname "$common")"
}

# Initials when the name has three or more words (split on - _ . and camel
# case), otherwise its first three letters. Only a starting point: the user
# confirms or picks another.
cmd_propose() {
  local name words
  name=$(cmd_repo)
  read -r -a words <<<"$(printf '%s' "$name" |
    sed -E 's/([a-z0-9])([A-Z])/\1 \2/g' | tr '_.-' '   ' |
    tr '[:upper:]' '[:lower:]')"
  if [ "${#words[@]}" -ge 3 ]; then
    printf '%s%s%s\n' "${words[0]:0:1}" "${words[1]:0:1}" "${words[2]:0:1}"
  else
    printf '%s' "${words[*]}" | tr -cd 'a-z0-9' | cut -c1-3
  fi
}

cmd_set() {
  local code=${1-} file tmp
  if ! [[ $code =~ ^[a-z0-9]{3}$ ]]; then
    echo "project-code: code must be 3 characters, a-z or 0-9: '$code'" >&2
    exit 1
  fi
  file=$(settings)
  mkdir -p "$(dirname "$file")"
  [ -f "$file" ] || echo '{}' >"$file"
  tmp=$(mktemp)
  jq --arg c "$code" '.env.PROJECT_CODE = $c' "$file" >"$tmp"
  mv -f "$tmp" "$file"
}

case ${1-get} in
get) cmd_get ;;
repo) cmd_repo ;;
propose) cmd_propose ;;
set) cmd_set "${2-}" ;;
-h | --help | help) usage ;;
*)
  usage >&2
  exit 1
  ;;
esac
```

- [x] **Step 4: Run test to verify it passes**

Run: `./test/project-code.sh` Expected: `all passed`, exit 0. Then `make test`
— every suite passes.

- [x] **Step 5: Commit**

```bash
git add bin/project-code test/project-code.sh
git commit -m "feat(bin): add project-code for the session title prefix"
```

---

### Task 2: `title` skill

**Files:**

- Create: `claude/skills/title/SKILL.md`

**Interfaces:**

- Consumes: `project-code get|propose|set` from Task 1 (installed to
  `~/.local/bin`; call by name, fall back to `<repo>/bin/project-code` when not
  on PATH).
- Produces: `/title [state] [id] [description]` — the invocation Tasks 3–4 put
  into other skills and CLAUDE.md. States accepted as emoji or word: `📥 reg`,
  `📝 plan`, `🔨 impl`, `🔍 rev`, `🛬 land`, `🚀 ship`, `✅ shipped`,
  `🚫 closed`.

- [x] **Step 1: Write the skill**

Create `claude/skills/title/SKILL.md`:

````markdown
---
name: title
description:
  Use when the user types /title, asks to name or rename the session ("renomeia
  a sessão", "atualiza o título"), or when another skill or CLAUDE.md says to
  set the session title for a state change.
---

# Title the session

The title shows, at a glance in the sidebar, the project, the tracker item and
where that item is in its life:

```
[<emoji> <code>-<id>] <description>
```

`[📝 dot-mrr] Session naming skill`. With no tracker item yet:
`[📥 dot] <description>`.

**Language.** The description follows the language the user is speaking.

## Arguments

None → guess every part. Any part given overrides the guess, in any order:

- a state, as emoji or word (table below);
- a tracker id (`dot-abc`, `qst-abc`);
- anything else → the description.

## States

| Emoji | Word      | When                                                           |
| ----- | --------- | -------------------------------------------------------------- |
| 📥    | `reg`     | the session only filed or edited tracker items                 |
| 📝    | `plan`    | brainstorming, spec or plan work, no product code edited       |
| 🔨    | `impl`    | code edited, or a plan being executed                          |
| 🔍    | `rev`     | preflight or a code review running                             |
| 🛬    | `land`    | land running, or landed and no code edited since               |
| 🚀    | `ship`    | ship running                                                   |
| ✅    | `shipped` | the item closed as shipped — the work is on the default branch |
| 🚫    | `closed`  | the item closed as cancelled, superseded or wontfix            |

Guessing: the latest of these signals in the session wins. ✅ never comes from
a guess alone — only when the work is in `origin/<default>`
(`git merge-base --is-ancestor HEAD <base>`) and the item is closed.

## Steps

1. **Project code.** Run `project-code` (on PATH after `make install`; else
   `bin/project-code` in the dotfiles repo). Exit 0 → use its output. Exit 2 →
   run `project-code propose`, ask the user to confirm it or type another
   (context in the reply: the repo name from `project-code repo`, the proposal,
   that it is saved in `.claude/settings.json` and ships with the branch). Then
   `project-code set <code>` and tell the user the file changed and needs
   committing with the branch. Exit 1 (not a git repo) → no code; the prefix is
   just `[<emoji>]`.
2. **Tracker.** From the repo root, first match wins: **Kingdone**
   (`Gates/Gates.md` exists; items are quests `qst-<id>`), **Beads** (`.beads/`
   exists and `command -v bd`), **neither** (no id in the title).
3. **Main item.** Candidates: items this session created, claimed or edited, an
   id in the branch name, one the conversation names. Then, in order:
   1. one candidate, or one clearly central → it;
   2. **supersede first** — one candidate covers the others (or they are
      duplicates): propose closing the rest as superseded by it (Beads:
      `bd supersede <other> --with=<main>`; Kingdone: the vault's own
      convention from its `CLAUDE.md`). Ask; write only on yes. The survivor is
      the main item;
   3. the rest share a parent → the parent;
   4. the rest share a topic, no parent → propose a new epic (title and
      children) and reparenting them under it (`bd create --type=epic`, then
      `bd update <child> --parent=<epic>`). Ask; write only on yes. The epic is
      the main item;
   5. unrelated → ask which one is main.

   The id in the title drops the tracker prefix and keeps any child suffix:
   `dot-mrr` → `mrr`, `dot-s52.3` → `s52.3`, `qst-abc` → `abc`.

4. **State.** Argument, else the table above.
5. **Description.** Argument; else the main item's title; else a short topic of
   the session. Trim to about 40 characters on a word boundary. When the
   current title already has a `[...]` prefix and its description still fits
   the main item, keep that description.
6. **Rename.** Load `mcp__ccd_session_mgmt__set_session_title` with ToolSearch
   if it is deferred, then call it for this session (`session_id: "self"`). If
   the tool does not exist (plain CLI), print `/rename <title>` in a code block
   for the user to run.
7. **Report.** One line: the new title.

Never fail hard: leave out any part that cannot be resolved; the worst case is
printing the proposed title.

## Common mistakes

- Taking the repo name from the worktree folder — always `project-code repo`.
- Setting ✅ because ship started, or because close ran with another reason.
- Writing a supersede or an epic without the user's yes.
- Dropping the user's description on every rename instead of swapping only the
  prefix.
````

- [x] **Step 2: Format and check**

Run: `npx --no-install prettier --check claude/skills/title/SKILL.md` (or
`prettier --check`). Fix with `--write` if needed. Expected: file passes.

- [x] **Step 3: Set this repo's code with the script**

Run from the worktree root:
`bin/project-code set dot && cat .claude/settings.json` Expected: existing
`enabledPlugins` and `hooks` intact, plus `"env": { "PROJECT_CODE": "dot" }`.
Then `npx --no-install prettier --write .claude/settings.json`.

- [x] **Step 4: Commit**

```bash
git add claude/skills/title/SKILL.md .claude/settings.json
git commit -m "feat(claude): add the title skill for session name prefixes"
```

---

### Task 3: Invoke `/title` from preflight, ship, close and CLAUDE.md

**Files:**

- Modify: `claude/skills/preflight/SKILL.md` (intro, after line 16 — before
  `**Language.**`)
- Modify: `claude/skills/ship/SKILL.md` (`## Steps`, before step 1; and step 5
  end)
- Modify: `claude/skills/close/SKILL.md` (`## 2. Archive` step a, after the
  task is marked done)
- Modify: `claude/CLAUDE.md` (new `## Session title` section at the end)

**Interfaces:**

- Consumes: `/title <state>` from Task 2.

If `dot-4v7` (land/ship/close split) has already landed on main when this task
runs, put 🔍 in preflight, 🛬 at land's start, 🚀 at ship's start, and ✅/🚫 in
close by reason, instead of the lines below.

- [x] **Step 1: preflight**

Insert before `**Language.**` in `claude/skills/preflight/SKILL.md`:

```markdown
**Title.** Before anything else, run the `title` skill with `🔍`, so the
session title shows the branch is under review.
```

- [x] **Step 2: ship**

Insert right after the `## Steps` heading paragraph (before step 1) in
`claude/skills/ship/SKILL.md`:

```markdown
Before step 1, run the `title` skill with `🚀`.
```

- [x] **Step 3: close**

In `claude/skills/close/SKILL.md`, step `2a` — right after the text that marks
the task done, add:

```markdown
Once the task is marked done (or there is none), run the `title` skill with
`✅`: the work is on the default branch now.
```

- [x] **Step 4: CLAUDE.md**

Append to `claude/CLAUDE.md`:

```markdown
## Session title

- Run the `title` skill whenever the session's state changes: a tracker item
  gets filed, a design or plan gets approved, implementation starts. The
  lifecycle skills (preflight, ship, close) run it themselves.
```

- [x] **Step 5: Format and commit**

Run:
`npx --no-install prettier --write claude/CLAUDE.md claude/skills/*/SKILL.md`
then `git diff --stat` (only the four files). Then:

```bash
git add claude/CLAUDE.md claude/skills/preflight/SKILL.md \
  claude/skills/ship/SKILL.md claude/skills/close/SKILL.md
git commit -m "feat(claude): set the session title from lifecycle skills"
```

---

### Task 4: Install, dogfood, tracker follow-ups

**Files:** none in the repo (install + tracker only).

- [x] **Step 1: Install**

Run: `make install`. Expected: `~/.claude/skills/title/SKILL.md` and
`~/.local/bin/project-code` exist.

- [x] **Step 2: Dogfood**

Invoke `/title` in this session. Expected title:
`[🔨 dot-mrr] Session naming skill: /title sets…` (trimmed). Then `/title 📝` →
emoji swaps, description kept.

- [x] **Step 3: dot-4v7 follow-up**

If `dot-4v7` has not landed:

```bash
bd update dot-4v7 --append-notes="When splitting: land runs the title skill with 🛬 at its start; close runs it with ✅ when the reason is shipped, 🚫 otherwise (see dot-mrr spec)."
```

- [x] **Step 4: dot-0oq**

Ask the user whether to close `dot-0oq` as superseded by `dot-mrr`
(`bd supersede dot-0oq --with=dot-mrr`). Write only on yes.
