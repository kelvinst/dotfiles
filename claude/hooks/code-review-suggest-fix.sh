#!/bin/bash
# Injects a suggested-fix requirement whenever a review skill is invoked.
# ReportFindings has no dedicated fix field, so the fix rides in
# `failure_scenario`, after the scenario text.

input=$(cat)
prompt=$(printf '%s' "$input" | /usr/bin/python3 -c 'import json,sys; print(json.load(sys.stdin).get("prompt",""))' 2>/dev/null)

case "$prompt" in
  */code-review*|*/ultrareview*|*/security-review*|*/simplify*) ;;
  *) exit 0 ;;
esac

cat <<'MSG'
Review finding format (overrides the default ReportFindings phrasing):

Every finding reported with ReportFindings MUST include a concrete suggested fix.
The tool schema has no fix field, so put it in `failure_scenario`, right after the
scenario: first the concrete inputs/state -> wrong output/crash, then two line
breaks (a blank line), then "Fix: " and the specific change to make — name the
function/variable/line and the new behavior (e.g. "Fix: change `<` to `<=` in the
expiry check on line 42" or "Fix: hoist the `redraw()` call out of the loop and
call it once after the loop"). Not generic advice like "add validation".
Keep `summary` as the one-sentence defect statement, with no fix text.
Keep `short_summary` as the bare claim, under 60 chars, no fix text.
MSG
