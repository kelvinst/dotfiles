#!/bin/bash
# Stop hook: commit the turn's work automatically, one commit per prompt.
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
[ -z "$dirty" ] && exit 0

# Beads churn alone is not progress worth a commit.
[ "$(printf '%s\n' "$dirty" | grep -cv '\.beads/issues\.jsonl$')" -eq 0 ] && exit 0

/usr/bin/python3 <<'PY'
import json

reason = """You left uncommitted work in the tree. Commit it now - do not ask first.

Pick the commit procedure, in this order:

1. `kix:commit` - preferred. Invoke it via the Skill tool and follow it fully;
   it owns staging, message generation and pre-commit hook fixes. Do not
   second-guess its staging strategy.
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

print(json.dumps({"decision": "block", "reason": reason}))
PY
