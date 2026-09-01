#!/bin/bash
# Stop hook: land the turn's work in a commit, one commit per prompt. Turns
# that changed no code end the turn as-is - session archives are not worth the
# tokens they cost to render.
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

# Main branch is scratch space: work there gets rolled back or moved onto a
# branch before it is committed. Never auto-commit onto the default branch.
branch=$(git -C "$repo" symbolic-ref --quiet --short HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  default=$(git -C "$repo" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  default="${default#origin/}"
  [ -n "$default" ] || default=main
  case "$branch" in
  "$default" | main | master) exit 0 ;;
  esac
fi

dirty=$(git -C "$repo" status --porcelain)

# Nothing dirty, or beads churn alone: no code progress, nothing to commit.
[ -n "$dirty" ] || exit 0
[ "$(printf '%s\n' "$dirty" | grep -cv '\.beads/issues\.jsonl$')" -gt 0 ] || exit 0

/usr/bin/python3 <<'PY'
import json

CODE = """You left uncommitted work in the tree. Commit it now - do not ask first.

Do NOT archive the session as part of this. That means: do not invoke
`kix:commit` (its staging step always calls `kix:save-session`), and do not
invoke `kix:save-session` or `anthropic-skills:save-session` directly.
Rendering the transcript every turn is not worth its cost.

Pick the commit procedure, in this order:

1. `caveman:caveman-commit` - preferred. Use it for the message, `git add` ONLY
   the files you edited this turn (never `git add -A` or `git add .`), then
   commit.
2. No commit skill available - write the message yourself: Conventional
   Commits, `<type>(<scope>): <subject>`, scope tied to the file or tool
   touched, subject imperative and <= 50 chars, body only when the why is not
   obvious and wrapped at ~72 chars, no Co-Authored-By trailer. Stage only what
   you edited.

Stage any `.beads/` churn alongside your own edits so the tree comes out clean.

Then report the short SHA in one line.

If everything dirty was edited by the user rather than you, say so and skip the
commit."""

print(json.dumps({"decision": "block", "reason": CODE}))
PY
