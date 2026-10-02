#!/usr/bin/env bash
# Regression tests for `obsidian-vault` (dot-73z).
#
# Stubs `pgrep`, `osascript` and `open` on PATH and points OBSIDIAN_CONFIG
# at a temp file, so no run quits or launches the real Obsidian or touches
# its vault list.
set -uo pipefail

SCRIPT=${SCRIPT:-"$(cd "$(dirname "$0")/.." && pwd)/bin/obsidian-vault"}
failures=0

setup() {
  work=$(mktemp -d)
  export OBSIDIAN_CONFIG="$work/obsidian.json"
  export STUB_LOG="$work/calls"
  export STUB_RUNNING="$work/running"
  : >"$STUB_LOG"
  mkdir -p "$work/bin"
  # pgrep succeeds while the "running" flag file exists; quitting drops it.
  cat >"$work/bin/pgrep" <<'STUB'
#!/bin/sh
[ -e "$STUB_RUNNING" ]
STUB
  cat >"$work/bin/osascript" <<'STUB'
#!/bin/sh
printf 'osascript %s\n' "$*" >>"$STUB_LOG"
rm -f "$STUB_RUNNING"
STUB
  cat >"$work/bin/open" <<'STUB'
#!/bin/sh
printf 'open %s\n' "$*" >>"$STUB_LOG"
STUB
  chmod +x "$work/bin/"*
  PATH="$work/bin:$PATH"
}

teardown() {
  PATH=${PATH#"$work/bin:"}
  rm -rf "$work"
}

check() {
  if [ "$2" = "$3" ]; then
    echo "ok   - $1"
  else
    echo "FAIL - $1"
    echo "       expected: $2"
    echo "       got:      $3"
    failures=$((failures + 1))
  fi
}

# A known folder opens by its id without quitting Obsidian.
setup
mkdir "$work/known"
printf '{"vaults":{"abc":{"path":"%s","ts":1}}}' "$work/known" >"$OBSIDIAN_CONFIG"
touch "$STUB_RUNNING"
"$SCRIPT" "$work/known"
check "known vault opens by id" "open obsidian://open?vault=abc" "$(cat "$STUB_LOG")"
teardown

# A new folder quits the running app, gets registered, then opens.
setup
printf '{"vaults":{"abc":{"path":"/elsewhere","ts":1}}}' >"$OBSIDIAN_CONFIG"
touch "$STUB_RUNNING"
"$SCRIPT" "$work/new/notes" 2>/dev/null
id=$(jq -r --arg p "$work/new/notes" \
  '.vaults | to_entries[] | select(.value.path == $p) | .key' "$OBSIDIAN_CONFIG")
check "new folder is created" "yes" "$([ -d "$work/new/notes" ] && echo yes)"
check "existing vaults are kept" "/elsewhere" "$(jq -r '.vaults.abc.path' "$OBSIDIAN_CONFIG")"
check "new vault id is 16 hex chars" "16" "$(printf %s "$id" | grep -qE "^[0-9a-f]{16}$" && echo 16)"
check "quits, then opens the new vault" \
  "osascript -e quit app \"Obsidian\"
open obsidian://open?vault=$id" "$(cat "$STUB_LOG")"
teardown

# No config yet and Obsidian closed: writes a fresh list, no quit.
setup
mkdir "$work/fresh"
(cd "$work/fresh" && "$SCRIPT")
check "registers cwd in a fresh config" "$work/fresh" \
  "$(jq -r '.vaults[].path' "$OBSIDIAN_CONFIG")"
check "no quit when not running" "1" "$(wc -l <"$STUB_LOG" | tr -d ' ')"
teardown

[ "$failures" -eq 0 ]
