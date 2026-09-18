#!/usr/bin/env bash
# Regression tests for `orbit sync-monitors` (dot-zq9).
#
# Nothing here touches the real aerospace: a stub on PATH answers the
# queries and records the mutations, and XDG_CACHE_HOME points at a temp
# dir so the state files orbit writes are the test's own. That keeps the
# run off the developer's live desktop — flattening workspaces and moving
# them between monitors to assert on a layout would be a rude test — and
# it means the result doesn't depend on what is plugged in right now.
set -uo pipefail

ORBIT=${ORBIT:-"$(cd "$(dirname "$0")/.." && pwd)/bin/orbit"}
failures=0

# Each case runs in its own sandbox: a fresh stub log and a fresh cache.
setup() {
  work=$(mktemp -d)
  export XDG_CACHE_HOME="$work/cache"
  export ORBIT_LOCK_DIR="$work/lock"
  export STUB_LOG="$work/calls"
  : >"$STUB_LOG"

  mkdir -p "$work/bin"
  cat >"$work/bin/aerospace" <<'STUB'
#!/bin/sh
# Records every invocation, then answers from the STUB_* environment.
printf '%s\n' "$*" >>"$STUB_LOG"

sub=$1
shift

has() {
  for a in "$@"; do [ "$a" = "$1" ] && return 0; done
  return 1
}

case $sub in
list-monitors)
  printf '%s\n' "${STUB_COUNT-1}"
  ;;
list-workspaces)
  fmt=0
  pop=0
  for a in "$@"; do
    [ "$a" = "--format" ] && fmt=1
    [ "$a" = "--empty" ] && pop=1
  done
  if [ "$fmt" -eq 1 ] && [ "$pop" -eq 1 ]; then
    printf '%s\n' "${STUB_WS_MON_POPULATED-}"
  elif [ "$fmt" -eq 1 ]; then
    printf '%s\n' "${STUB_WS_MON_ALL-}"
  else
    printf '%s\n' "${STUB_WS-}"
  fi
  ;;
list-windows)
  # `<window-id> <layout>` for the requested workspace. Every workspace
  # gets one window, in STUB_LAYOUT.
  ws=""
  prev=""
  for a in "$@"; do
    [ "$prev" = "--workspace" ] && ws=$a && break
    prev=$a
  done
  printf 'win_%s %s\n' "$ws" "${STUB_LAYOUT-h_accordion}"
  ;;
layout)
  exit "${STUB_LAYOUT_RC-0}"
  ;;
*)
  # flatten-workspace-tree, move-workspace-to-monitor, and friends.
  exit "${STUB_MUTATE_RC-0}"
  ;;
esac
STUB
  chmod +x "$work/bin/aerospace"
  PATH="$work/bin:$PATH"
  export PATH
}

teardown() { rm -rf "$work"; }

state_file() { echo "$XDG_CACHE_HOME/orbit/monitors"; }
state() { cat "$(state_file)" 2>/dev/null || echo "<missing>"; }
# `grep -c` prints 0 and exits 1 on no match, so it needs no fallback —
# one would print a second count.
layout_calls() { grep -c '^layout ' "$STUB_LOG" 2>/dev/null; }

check() {
  local what=$1 got=$2 want=$3
  if [ "$got" = "$want" ]; then
    echo "  ok: $what"
  else
    echo "  FAIL: $what — got [$got], want [$want]"
    failures=$((failures + 1))
  fi
}

# --- dot-zq9 -------------------------------------------------------------
# `aerospace layout X accordion` exits 1 when accordion is already in
# force, which is exactly the state an undock finds. Reading that as a
# failure meant the mode was never recorded, and the stale state file then
# made the next dock a no-op. The layout must not even be asked for.
echo "already in the target layout: skipped, run still succeeds"
setup
STUB_COUNT=1 STUB_WS=$'1\n2' STUB_LAYOUT=h_accordion STUB_LAYOUT_RC=1 \
  "$ORBIT" sync-monitors --force
check "exit status" "$?" "0"
check "recorded mode" "$(state)" "solo"
check "layout calls" "$(layout_calls)" "0"
teardown

echo "not in the target layout: layout applied"
setup
STUB_COUNT=1 STUB_WS=$'1\n2' STUB_LAYOUT=h_tiles STUB_LAYOUT_RC=0 \
  "$ORBIT" sync-monitors --force
check "exit status" "$?" "0"
check "recorded mode" "$(state)" "solo"
check "layout calls" "$(layout_calls)" "2"
teardown

# --- the failure paths the skip must not swallow -------------------------
echo "a real layout failure still fails the run"
setup
STUB_COUNT=1 STUB_WS=$'1\n2' STUB_LAYOUT=h_tiles STUB_LAYOUT_RC=1 \
  "$ORBIT" sync-monitors --force
check "exit status" "$?" "1"
check "recorded mode" "$(state)" "<missing>"
teardown

echo "an unreadable monitor count aborts without recording"
setup
STUB_COUNT="" STUB_WS=$'1\n2' "$ORBIT" sync-monitors --force
check "exit status" "$?" "1"
check "recorded mode" "$(state)" "<missing>"
teardown

# --- the dock direction --------------------------------------------------
echo "external: workspaces seeded and mode recorded"
setup
STUB_COUNT=2 \
  STUB_WS_MON_ALL=$'0 2\n1 1\n2 1' \
  STUB_WS_MON_POPULATED=$'1 1\n2 1' \
  STUB_LAYOUT=h_accordion STUB_LAYOUT_RC=0 \
  "$ORBIT" sync-monitors --force
check "exit status" "$?" "0"
check "recorded mode" "$(state)" "external"
check "0/G/M/P seeded" "$(grep -c '^move-workspace-to-monitor ' "$STUB_LOG")" "4"
teardown

# --- the early return ----------------------------------------------------
echo "an unchanged mode is left alone"
setup
mkdir -p "$XDG_CACHE_HOME/orbit"
printf 'solo\n' >"$(state_file)"
STUB_COUNT=1 STUB_WS=$'1\n2' "$ORBIT" sync-monitors
check "exit status" "$?" "0"
check "nothing mutated" "$(wc -l <"$STUB_LOG" | tr -d ' ')" "1"
teardown

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures check(s) failed"
fi
exit $((failures > 0))
