#!/usr/bin/env bash
# Regression tests for `scry` (dot-73z, dot-ffu.2).
#
# Stubs `pgrep`, `open` and Obsidian's `obsidian` CLI on PATH. The stub
# CLI keeps a fake vault list in a JSON file and acts on the IPC messages
# scry sends through `eval`, so no run launches the real app or touches
# its vault list.
set -uo pipefail

SCRIPT=${SCRIPT:-"$(cd "$(dirname "$0")/.." && pwd)/bin/scry"}
failures=0

setup() {
  work=$(mktemp -d)
  export STUB_LOG="$work/calls"
  export STUB_RUNNING="$work/running"
  export STUB_VAULTS="$work/vaults.json"
  export SCRY_WAIT=1
  unset STUB_OPEN_REPLY STUB_OPEN_ADD STUB_REMOVE_REFUSE
  echo '{}' >"$STUB_VAULTS"
  : >"$STUB_LOG"
  mkdir -p "$work/bin"
  # pgrep succeeds while the "running" flag file exists; `open` creates it.
  cat >"$work/bin/pgrep" <<'STUB'
#!/bin/sh
[ -e "$STUB_RUNNING" ]
STUB
  cat >"$work/bin/open" <<'STUB'
#!/bin/sh
printf 'launch %s\n' "$*" >>"$STUB_LOG"
touch "$STUB_RUNNING"
STUB
  # Logs one line per effect (open/close/remove/passthrough); reads such
  # as the readiness probe and vault-list are not logged.
  # Like the real CLI, it drains whatever stdin it is handed.
  cat >"$work/bin/obsidian" <<'STUB'
#!/bin/sh
input=$(cat)
[ -e "$STUB_RUNNING" ] || exit 1
target= code= is_eval=
for a; do
  case $a in
  eval) is_eval=1 ;;
  vault=*) target=${a#vault=} ;;
  code=*) code=$(printf '%s' "${a#code=}" | tr '\n' ' ') ;;
  esac
done
[ -n "$is_eval" ] || {
  printf 'passthrough %s%s\n' "$*" "${input:+ stdin=$input}" >>"$STUB_LOG"
  exit 0
}
# The JSON string argument following an IPC message name, decoded.
arg() {
  printf '%s' "$code" | sed -n "s/.*'$1', \(\"[^)]*\"\)[,)].*/\1/p" | jq -r .
}
set_vaults() {
  jq "$@" "$STUB_VAULTS" >"$STUB_VAULTS.tmp" && mv "$STUB_VAULTS.tmp" "$STUB_VAULTS"
}
case "$code" in
1) echo "=> 1" ;;
*vault-list*) printf '=> %s\n' "$(jq -c . "$STUB_VAULTS")" ;;
*vault-open*)
  p=$(arg vault-open)
  printf 'open %s\n' "$p" >>"$STUB_LOG"
  if [ "${STUB_OPEN_ADD:-1}" = 1 ]; then
    id=$(jq -r --arg p "$p" 'to_entries[] | select(.value.path == $p) | .key' "$STUB_VAULTS")
    [ -n "$id" ] || id="id$(jq length "$STUB_VAULTS")"
    set_vaults --arg id "$id" --arg p "$p" '.[$id] = {path: $p, open: true}'
  fi
  echo "${STUB_OPEN_REPLY-=> true}"
  ;;
*window.close*)
  printf 'close %s\n' "$target" >>"$STUB_LOG"
  set_vaults --arg id "$target" '.[$id].open = false'
  ;;
*vault-remove*)
  p=$(arg vault-remove)
  printf 'remove %s\n' "$p" >>"$STUB_LOG"
  if [ -n "${STUB_REMOVE_REFUSE:-}" ]; then echo "=> false"; exit 0; fi
  set_vaults --arg p "$p" 'with_entries(select(.value.path != $p))'
  echo "=> true"
  ;;
*) echo "=> unexpected" ;;
esac
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

# Seeds the fake vault list: add_vault <id> <path> <open:true|false>.
add_vault() {
  jq --arg id "$1" --arg p "$2" --argjson o "$3" '.[$id] = {path: $p, open: $o}' \
    "$STUB_VAULTS" >"$STUB_VAULTS.tmp" && mv "$STUB_VAULTS.tmp" "$STUB_VAULTS"
}

# open: running app, new folder with quotes in its name.
setup
touch "$STUB_RUNNING"
dir="$work/my \"notes\""
"$SCRIPT" open "$dir"
check "open: exit status" "0" "$?"
check "open: folder is created" "yes" "$([ -d "$dir" ] && echo yes)"
check "open: sends vault-open with the path" "open $dir" "$(cat "$STUB_LOG")"
teardown

# open: closed app is launched first; dir defaults to the cwd.
setup
mkdir "$work/here"
(cd "$work/here" && "$SCRIPT" open)
check "open: launches Obsidian, then opens cwd" \
  "launch -a Obsidian
open $work/here" "$(cat "$STUB_LOG")"
teardown

# open: Obsidian refuses the folder.
setup
touch "$STUB_RUNNING"
export STUB_OPEN_REPLY="=> no permission to access folder" STUB_OPEN_ADD=0
err=$("$SCRIPT" open "$work/x" 2>&1)
check "open: refusal fails" "1" "$?"
check "open: refusal reason is shown" \
  "scry: could not open $work/x: no permission to access folder" "$err"
teardown

# open: dropped reply is checked against the vault list.
setup
touch "$STUB_RUNNING"
export STUB_OPEN_REPLY=""
"$SCRIPT" open "$work/z z"
check "open: empty reply with vault listed succeeds" "0" "$?"
export STUB_OPEN_ADD=0
err=$("$SCRIPT" open "$work/other" 2>&1)
check "open: empty reply without vault listed fails" "1" "$?"
check "open: empty reply reason" "scry: could not open $work/other: no reply" "$err"
teardown

# open: CLI never answers (e.g. turned off).
setup
cat >"$work/bin/open" <<'STUB'
#!/bin/sh
printf 'launch %s\n' "$*" >>"$STUB_LOG"
STUB
"$SCRIPT" open "$work/y" 2>/dev/null
check "open: silent CLI fails" "1" "$?"
check "open: only the launch was attempted" "launch -a Obsidian" "$(cat "$STUB_LOG")"
teardown

# remove: an open vault is closed first, then removed.
setup
touch "$STUB_RUNNING"
mkdir "$work/a"
add_vault keep /keep true
add_vault ida "$work/a" true
"$SCRIPT" remove "$work/a/"
check "remove: exit status" "0" "$?"
check "remove: closes, then removes" "close ida
remove $work/a" "$(cat "$STUB_LOG")"
check "remove: other vaults stay" "keep" "$(jq -r 'keys | join(",")' "$STUB_VAULTS")"
check "remove: folder stays on disk" "yes" "$([ -d "$work/a" ] && echo yes)"
teardown

# remove: unknown path, and a refusal from Obsidian.
setup
touch "$STUB_RUNNING"
err=$("$SCRIPT" remove "$work/nope" 2>&1)
check "remove: unknown vault fails" "1" "$?"
check "remove: unknown vault reason" "scry: not a known vault: $work/nope" "$err"
add_vault idb /b false
export STUB_REMOVE_REFUSE=1
err=$("$SCRIPT" remove /b 2>&1)
check "remove: refusal fails" "1" "$?"
check "remove: refusal reason" \
  "scry: could not remove /b: Obsidian refused; is it the only vault open?" "$err"
teardown

# prune: only vaults whose folder is gone go, open or not.
setup
touch "$STUB_RUNNING"
mkdir "$work/alive"
add_vault alive "$work/alive" true
add_vault gone1 "$work/gone1" false
add_vault gone2 "$work/gone2" true
out=$("$SCRIPT" prune -n)
check "prune -n: lists missing folders" "$work/gone1
$work/gone2" "$out"
check "prune -n: changes nothing" "" "$(cat "$STUB_LOG")"
"$SCRIPT" prune >/dev/null
check "prune: exit status" "0" "$?"
check "prune: removes missing ones only" "alive" "$(jq -r 'keys | join(",")' "$STUB_VAULTS")"
check "prune: closes the open one first" "remove $work/gone1
close gone2
remove $work/gone2" "$(cat "$STUB_LOG")"
teardown

# list and passthrough.
setup
touch "$STUB_RUNNING"
add_vault ida /a true
add_vault idb "/b c" false
check "list: id, state, path" "ida	open	/a
idb	closed	/b c" "$("$SCRIPT" list)"
echo hi | "$SCRIPT" search query=foo
"$SCRIPT" </dev/null
check "unknown and no commands go to obsidian, stdin intact" \
  "passthrough search query=foo stdin=hi
passthrough " "$(cat "$STUB_LOG")"
teardown

[ "$failures" -eq 0 ]
