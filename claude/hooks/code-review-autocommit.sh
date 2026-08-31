#!/bin/bash
# Commits each fix applied from a report-findings card.
# The "Apply fix" button injects a fixed prompt prefix; match on it.

input=$(cat)
prompt=$(printf '%s' "$input" | /usr/bin/python3 -c 'import json,sys; print(json.load(sys.stdin).get("prompt",""))' 2>/dev/null)

case "$prompt" in
  "Apply this code-review finding with the minimal edit."*) ;;
  *) exit 0 ;;
esac

cat <<'MSG'
After applying this finding, commit it — do not ask first, and do not batch it
with a later fix:

1. `git add` ONLY the files you just edited for this finding. Never `git add -A`
   or `git add .` — other unrelated work may be in the tree.
2. `git commit` with a Conventional Commits message: `<type>(<scope>): <subject>`,
   subject imperative and <= 50 chars. Type from what the fix does (`fix:` for a
   bug, `perf:`, `refactor:`). Body only if the "why" isn't obvious from the
   subject; if you add one, state the failure the finding described.
3. Report the short SHA in your reply.

If you concluded no edit was needed, skip the commit and say so.
MSG
