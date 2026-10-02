#!/usr/bin/env bash
# Regression tests for `obsidian-vault` (dot-73z).
#
# Stubs `pgrep`, `open` and Obsidian's `obsidian` CLI on PATH, so no run
# launches the real app or adds a vault to its list.
set -uo pipefail

SCRIPT=${SCRIPT:-"$(cd "$(dirname "$0")/.." && pwd)/bin/obsidian-vault"}
failures=0

setup() {
  work=$(mktemp -d)
  export STUB_LOG="$work/calls"
  export STUB_RUNNING="$work/running"
  export STUB_RESULT="=> true"
  export OBSIDIAN_VAULT_WAIT=1
  : >"$STUB_LOG"
  mkdir -p "$work/bin"
  # pgrep succeeds while the "running" flag file exists; `open` creates it.
  cat >"$work/bin/pgrep" <<'STUB'
#!/bin/sh
[ -e "$STUB_RUNNING" ]
STUB
  cat >"$work/bin/open" <<'STUB'
#!/bin/sh
printf 'open %s\n' "$*" >>"$STUB_LOG"
touch "$STUB_RUNNING"
STUB
  # The CLI only answers while the app runs; the readiness probe
  # (code=1) is not logged so the log shows the real call alone.
  cat >"$work/bin/obsidian" <<'STUB'
#!/bin/sh
[ -e "$STUB_RUNNING" ] || exit 1
[ "$2" = "code=1" ] && { echo "=> 1"; exit 0; }
[ "$1" = "vaults" ] && { printf 'v\t%s\n' "${STUB_VAULT:-}"; exit 0; }
printf '%s\n' "$*" >>"$STUB_LOG"
echo "$STUB_RESULT"
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

# Running app: one vault-open eval with the folder as a JSON string.
setup
touch "$STUB_RUNNING"
dir="$work/my \"notes\""
"$SCRIPT" "$dir"
check "exit status" "0" "$?"
check "folder is created" "yes" "$([ -d "$dir" ] && echo yes)"
check "sends vault-open with the escaped path" \
  "eval code=window.electron.ipcRenderer.sendSync('vault-open', \"$work/my \\\"notes\\\"\", false)" \
  "$(cat "$STUB_LOG")"
teardown

# Closed app: launches it, then opens the current directory.
setup
mkdir "$work/here"
(cd "$work/here" && "$SCRIPT")
check "launches Obsidian, then sends vault-open" \
  "open -a Obsidian
eval code=window.electron.ipcRenderer.sendSync('vault-open', \"$work/here\", false)" \
  "$(cat "$STUB_LOG")"
teardown

# Obsidian refuses the folder: its reason surfaces, exit fails.
setup
touch "$STUB_RUNNING"
export STUB_RESULT="=> no permission to access folder"
err=$("$SCRIPT" "$work/x" 2>&1)
check "refusal fails the run" "1" "$?"
check "refusal reason is shown" \
  "obsidian-vault: could not open $work/x: no permission to access folder" "$err"
teardown

# Empty reply (new window ate it): trusts the vault list instead.
setup
touch "$STUB_RUNNING"
export STUB_RESULT=""
export STUB_VAULT="$work/z z"
"$SCRIPT" "$work/z z"
check "empty reply with vault listed succeeds" "0" "$?"
err=$("$SCRIPT" "$work/other" 2>&1)
check "empty reply without vault listed fails" "1" "$?"
check "empty reply reason" "obsidian-vault: could not open $work/other: no reply" "$err"
unset STUB_VAULT
teardown

# CLI never answers (e.g. turned off): fails without sending anything.
setup
cat >"$work/bin/open" <<'STUB'
#!/bin/sh
printf 'open %s\n' "$*" >>"$STUB_LOG"
STUB
"$SCRIPT" "$work/y" 2>/dev/null
check "silent CLI fails the run" "1" "$?"
check "only the launch was attempted" "open -a Obsidian" "$(cat "$STUB_LOG")"
teardown

[ "$failures" -eq 0 ]
