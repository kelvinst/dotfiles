#!/bin/bash
# Stop hook: land the turn's work in a commit, one commit per prompt, via
# /kix:commit - the project's commit procedure owns staging, message style and
# pre-commit hook auto-fix, so this hook does not restate any of it.
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

Run `/kix:commit !` and follow that skill exactly. The leading `!` puts it in
auto-fix mode so pre-commit hook failures get diagnosed and retried instead of
aborting the turn. Do not hand-roll the staging, the message, or the fix loop -
the skill owns all three.

Then report the short SHA in one line.

If everything dirty was edited by the user rather than you, say so and skip the
commit."""

print(json.dumps({"decision": "block", "reason": CODE}))
PY
