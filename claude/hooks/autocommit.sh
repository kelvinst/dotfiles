#!/bin/bash
# Stop hook: land the turn's work in a commit, one commit per prompt. Turns
# that changed no code still get their session archive committed, so the
# reasoning behind a discussion-only turn is not lost.
# Guards first so we never burn a turn when there is nothing safe to commit.

input=$(cat)

read -r stop_active cwd <<<"$(printf '%s' "$input" | /usr/bin/python3 -c '
import json, sys
d = json.load(sys.stdin)
print("1" if d.get("stop_hook_active") else "0", d.get("cwd", ""))
' 2>/dev/null)"

# Already continuing from this hook - do not loop.
[ "$stop_active" = "1" ] && exit 0

repo="${cwd:-$PWD}"
git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Mid rebase/merge/cherry-pick/revert/bisect: committing corrupts the operation.
for op in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD BISECT_LOG; do
  [ -e "$(git -C "$repo" rev-parse --git-path "$op" 2>/dev/null)" ] && exit 0
done

dirty=$(git -C "$repo" status --porcelain)

# Beads churn alone is not progress worth a code commit - archive only.
if [ -n "$dirty" ] &&
  [ "$(printf '%s\n' "$dirty" | grep -cv '\.beads/issues\.jsonl$')" -gt 0 ]; then
  export HOOK_MODE=code
else
  export HOOK_MODE=archive
fi

/usr/bin/python3 <<'PY'
import json, os

CODE = """You left uncommitted work in the tree. Commit it now - do not ask first.

Pick the commit procedure, in this order:

1. `kix:commit` - preferred. Invoke it via the Skill tool and follow it fully;
   it owns staging, message generation and pre-commit hook fixes, and it
   bundles this session's archive into the same commit. Do not second-guess
   its staging strategy.
2. `caveman:caveman-commit` - fallback if kix is unavailable. Use it for the
   message, `git add` ONLY the files you edited this turn (never `git add -A`
   or `git add .`), then commit.
3. No commit skill available - write the message yourself: Conventional
   Commits, `<type>(<scope>): <subject>`, scope tied to the file or tool
   touched, subject imperative and <= 50 chars, body only when the why is not
   obvious and wrapped at ~72 chars, no Co-Authored-By trailer. Stage only what
   you edited.

Then report the short SHA in one line.

If everything dirty was edited by the user rather than you, say so and skip the
commit."""

ARCHIVE = """No code changed this turn, but the reasoning did. Archive the session now -
do not ask first.

1. Invoke `kix:save-session` via the Skill tool with `--no-commit`. It writes
   this session's archive into `docs/sessions/<stem>/` and `git add`s it
   without committing, so nothing opens a pull request. Use the kix skill -
   NOT `anthropic-skills:save-session`, which does open one.
2. `git add` any `.beads/` churn too, so the tree comes out clean.
3. Commit exactly those staged paths yourself: `docs: save session - <title>`
   for a new archive, `docs: update saved session - <title>` when
   save-session reported a re-save. `<title>` is the title save-session
   resolved. No other files, no Co-Authored-By trailer.

Then report the short SHA in one line.

If `kix:save-session` is unavailable here, or it reports no conversation
content to save, say so in one line and skip the commit."""

print(json.dumps({
    "decision": "block",
    "reason": CODE if os.environ["HOOK_MODE"] == "code" else ARCHIVE,
}))
PY
