#!/usr/bin/env bash
# Regression tests for the pkill-guard PreToolUse hook (dot-9gg).
#
# Feeds the hook Bash tool inputs on stdin and checks whether it denies
# them. Nothing is killed: the hook only reads the command text.
set -uo pipefail

HOOK=${HOOK:-"$(cd "$(dirname "$0")/.." && pwd)/claude/hooks/pkill-guard.sh"}
failures=0

decide() {
  /usr/bin/python3 -c 'import json,sys; print(json.dumps({"tool_name": "Bash", "tool_input": {"command": sys.argv[1]}}))' "$1" |
    bash "$HOOK" | grep -q '"deny"' && echo deny || echo allow
}

expect() {
  local want=$1 cmd=$2 got
  got=$(decide "$cmd")
  if [ "$got" = "$want" ]; then
    echo "ok   $want: $cmd"
  else
    echo "FAIL want $want, got $got: $cmd"
    failures=$((failures + 1))
  fi
}

expect deny 'pkill -f "cat" -U $(id -u) -P $$ 2>/dev/null; pkill -f "x.lua"'
expect deny 'pkill -f "hs -c"'
expect deny 'echo hi && pkill Obsidian'
expect deny 'sudo pkill -9 -f http.server'
expect deny 'killall -m "Obs.*"'
expect deny 'cd /tmp; pkill -U 501 cat'
expect deny 'pkill -TERM cat'
expect deny 'pkill -STOP -f cat'
expect allow 'pkill -x Obsidian'
expect allow 'pkill -TERM -x Obsidian'
expect allow 'pkill -9 -x AeroSpace 2>/dev/null || :'
expect allow 'pkill -f "^/Applications/Obsidian.app/"'
expect allow 'killall Obsidian'
expect allow 'pgrep -lf cat'
expect allow 'grep -n "pkill -f cat" notes.md'
expect allow 'kill 1234'

if [ "$failures" -gt 0 ]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "all passed"
