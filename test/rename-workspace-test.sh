#!/usr/bin/env bash
# Tests for workspace labels (dot-mjd): `orbit rename-workspace`, the
# number lookup behind `orbit workspace N` and friends, and labels
# travelling with their windows through `orbit move-workspace`.
#
# The aerospace stub keeps a tiny world in files — which workspace each
# window is on, which workspace is focused — so the commands can be run
# for their effect on it, without the live window manager.
set -uo pipefail

ORBIT=${ORBIT:-"$(cd "$(dirname "$0")/.." && pwd)/bin/orbit"}
failures=0

# Each case gets a fresh world. $1 is the focused workspace, the rest
# `<window-id>=<workspace>` pairs.
setup() {
  work=$(mktemp -d)
  export XDG_CACHE_HOME="$work/cache"
  export XDG_STATE_HOME="$work/state"
  export ORBIT_LOCK_DIR="$work/lock"
  export STUB_DIR="$work/world"
  mkdir -p "$STUB_DIR" "$work/bin"
  printf '%s\n' "$1" >"$STUB_DIR/focused"
  shift
  : >"$STUB_DIR/windows"
  for pair in "$@"; do
    printf '%s|%s\n' "${pair%%=*}" "${pair#*=}" >>"$STUB_DIR/windows"
  done
  # Persistent workspaces, there even when empty: none, as configured.
  : >"$STUB_DIR/persistent"
  : >"$STUB_DIR/calls"

  cat >"$work/bin/aerospace" <<'STUB'
#!/bin/sh
printf '%s\n' "$*" >>"$STUB_DIR/calls"
W="$STUB_DIR/windows"
F="$STUB_DIR/focused"

arg_after() {
  want=$1
  shift
  prev=""
  for a in "$@"; do
    [ "$prev" = "$want" ] && { printf '%s\n' "$a"; return; }
    prev=$a
  done
}
last() { for a in "$@"; do :; done; printf '%s\n' "$a"; }

sub=$1
shift
case $sub in
list-workspaces)
  if [ "$1" = "--focused" ]; then
    cat "$F"
  else
    { cut -d'|' -f2 "$W"; cat "$STUB_DIR/persistent" "$F"; } | sort -u
  fi
  ;;
list-windows)
  fmt=$(arg_after --format "$@")
  if [ "$1" = "--focused" ]; then
    ws=$(cat "$F")
    awk -F'|' -v ws="$ws" '$2 == ws {print $1; exit}' "$W"
    exit
  fi
  ws=$(arg_after --workspace "$@")
  awk -F'|' -v ws="$ws" -v fmt="$fmt" '$2 == ws {
    print (fmt ~ /layout/ ? "h_tiles" : $1)
  }' "$W"
  ;;
workspace | summon-workspace)
  last "$@" >"$F"
  ;;
move-node-to-workspace)
  id=$(arg_after --window-id "$@")
  to=$(last "$@")
  awk -F'|' -v OFS='|' -v id="$id" -v to="$to" '$1 == id {$2 = to} {print}' \
    "$W" >"$W.new" && mv "$W.new" "$W"
  ;;
list-monitors)
  printf '%s\n' "${STUB_MONITORS-1}"
  ;;
focus)
  id=$(arg_after --window-id "$@")
  awk -F'|' -v id="$id" '$1 == id {print $2}' "$W" >"$F"
  ;;
esac
exit 0
STUB
  chmod +x "$work/bin/aerospace"
  PATH="$work/bin:$PATH"
  export PATH
}

teardown() { rm -rf "$work"; }

focused() { cat "$STUB_DIR/focused"; }
# Workspace of window $1.
on() { awk -F'|' -v id="$1" '$1 == id {print $2}' "$STUB_DIR/windows"; }
# The last aerospace call orbit made.
last_call() { tail -n1 "$STUB_DIR/calls"; }

check() {
  local what=$1 got=$2 want=$3
  if [ "$got" = "$want" ]; then
    echo "  ok: $what"
  else
    echo "  FAIL: $what — got [$got], want [$want]"
    failures=$((failures + 1))
  fi
}

echo "rename: windows move to the labeled name, focus stays on them"
setup 1 a=1 b=1 c=2
"$ORBIT" rename-workspace Code
check "exit status" "$?" "0"
check "window a" "$(on a)" "1⠀Code"
check "window b" "$(on b)" "1⠀Code"
check "other workspace untouched" "$(on c)" "2"
check "focused" "$(focused)" "1⠀Code"
teardown

echo "rename: spaces in the label become gaps, extra ones dropped"
setup 2 a=2
"$ORBIT" rename-workspace "  Web   stuff "
check "window a" "$(on a)" "2⠀Web⠀stuff"
teardown

echo "rename: a new label replaces the old one"
setup "1⠀Code" a="1⠀Code"
"$ORBIT" rename-workspace Notes
check "window a" "$(on a)" "1⠀Notes"
teardown

echo "rename: an empty label goes back to the bare number"
setup "1⠀Code" a="1⠀Code"
"$ORBIT" rename-workspace ""
check "window a" "$(on a)" "1"
check "focused" "$(focused)" "1"
teardown

echo "rename: a workspace with no position number is refused"
setup splash
"$ORBIT" rename-workspace Code 2>/dev/null
check "exit status" "$?" "1"
teardown

echo "rename: the preset state follows the windows"
setup 1 a=1
mkdir -p "$XDG_CACHE_HOME/orbit/preset"
echo saved >"$XDG_CACHE_HOME/orbit/preset/1"
"$ORBIT" rename-workspace Code
check "state moved" "$(cat "$XDG_CACHE_HOME/orbit/preset/1⠀Code" 2>/dev/null)" "saved"
check "old state gone" "$([ -e "$XDG_CACHE_HOME/orbit/preset/1" ] && echo yes || echo no)" "no"
teardown

echo "workspace N: finds the labeled workspace at that position"
setup 2 a="1⠀Code" b=2
"$ORBIT" workspace 1
check "aerospace call" "$(last_call)" "workspace 1⠀Code"
teardown

echo "workspace N: falls back to the bare number"
setup 2 b=2
"$ORBIT" workspace 3
check "aerospace call" "$(last_call)" "workspace 3"
teardown

echo "workspace N: 1 does not match a labeled 10"
setup 2 a="10⠀Big"
"$ORBIT" workspace 1
check "aerospace call" "$(last_call)" "workspace 1"
teardown

echo "move-node-to-workspace N: flags before the number pass through"
setup 2 a="1⠀Code" b=2
"$ORBIT" move-node-to-workspace --focus-follows-window 1
check "aerospace call" "$(last_call)" "move-node-to-workspace --focus-follows-window 1⠀Code"
teardown

echo "workspace next: made explicit about stdin, which aerospace 0.20 needs"
setup 2 a="1⠀Code" b=2
"$ORBIT" workspace --wrap-around next
check "aerospace call" "$(last_call)" "workspace --no-stdin --wrap-around next"
teardown

echo "workspace next: an explicit --stdin is left alone"
setup 2 b=2
"$ORBIT" workspace --wrap-around --stdin next </dev/null
check "aerospace call" "$(last_call)" "workspace --wrap-around --stdin next"
teardown

echo "move-workspace: labels travel with their windows"
setup "1⠀Code" a="1⠀Code" b="3⠀Web"
"$ORBIT" move-workspace 3
check "exit status" "$?" "0"
check "Code windows" "$(on a)" "3⠀Code"
check "Web windows" "$(on b)" "1⠀Web"
check "focus stays at position 1" "$(focused)" "1⠀Web"
teardown

echo "move-workspace: into an empty position"
setup "1⠀Code" a="1⠀Code"
"$ORBIT" move-workspace --focus-follows-workspace 4
check "Code windows" "$(on a)" "4⠀Code"
check "focus follows" "$(focused)" "4⠀Code"
teardown

echo "move-workspace: same position is a no-op"
setup "1⠀Code" a="1⠀Code"
"$ORBIT" move-workspace 1
check "Code windows" "$(on a)" "1⠀Code"
check "no moves" "$(grep -c '^move-node-to-workspace' "$STUB_DIR/calls")" "0"
teardown

echo "move-workspace: unlabeled swap still works"
setup 1 a=1 b=2
mkdir -p "$XDG_CACHE_HOME/orbit/preset"
echo one >"$XDG_CACHE_HOME/orbit/preset/1"
echo two >"$XDG_CACHE_HOME/orbit/preset/2"
"$ORBIT" move-workspace 2
check "a" "$(on a)" "2"
check "b" "$(on b)" "1"
check "state of 1" "$(cat "$XDG_CACHE_HOME/orbit/preset/1")" "two"
check "state of 2" "$(cat "$XDG_CACHE_HOME/orbit/preset/2")" "one"
teardown

# --- saved labels --------------------------------------------------------
labels() { tr '\t\n' '= ' <"$XDG_STATE_HOME/orbit/labels" 2>/dev/null; }
save() {
  mkdir -p "$XDG_STATE_HOME/orbit"
  printf '%s\n' "$@" | tr '=' '\t' >"$XDG_STATE_HOME/orbit/labels"
}

echo "saved: a rename is remembered, a new one replaces it"
setup 1 a=1 b=2
"$ORBIT" rename-workspace Code
"$ORBIT" rename-workspace Notes
check "labels" "$(labels)" "1=Notes "
teardown

echo "saved: an empty label forgets it"
setup "1⠀Code" a="1⠀Code"
save "1=Code" "2=Web"
"$ORBIT" rename-workspace ""
check "labels" "$(labels)" "2=Web "
teardown

echo "saved: going to an emptied position brings its label back"
setup 2 b=2
save "1=Code"
"$ORBIT" workspace 1
check "aerospace call" "$(last_call)" "workspace 1⠀Code"
teardown

echo "saved: a labeled 0 brought back goes to the secondary monitor"
setup 2 b=2
save "0=Chat"
STUB_MONITORS=2 "$ORBIT" workspace 0
check "aerospace call" "$(grep -c '^move-workspace-to-monitor --workspace 0⠀Chat secondary$' "$STUB_DIR/calls")" "1"
teardown

echo "saved: not moved with one monitor, or when it already exists"
setup 2 a="0⠀Chat" b=2
"$ORBIT" workspace 0
STUB_MONITORS=2 "$ORBIT" workspace 0
check "no monitor moves" "$(grep -c '^move-workspace-to-monitor' "$STUB_DIR/calls")" "0"
teardown

echo "saved: move-workspace swaps the saved labels"
setup "1⠀Code" a="1⠀Code" b="3⠀Web"
save "1=Code" "3=Web"
"$ORBIT" move-workspace 3
check "labels" "$(labels | tr ' ' '\n' | sort | tr '\n' ' ')" "1=Web 3=Code "
teardown

echo "restore: windows on a bare number move to its saved label"
setup 2 a=1 b=1 c=2
save "1=Code" "4=Empty"
"$ORBIT" restore-labels
check "exit status" "$?" "0"
check "window a" "$(on a)" "1⠀Code"
check "window b" "$(on b)" "1⠀Code"
check "unlabeled untouched" "$(on c)" "2"
check "focus kept" "$(focused)" "2"
teardown

echo "restore: an already labeled position is left alone"
setup 2 a="1⠀Code" b=1
save "1=Code"
"$ORBIT" restore-labels
check "stray bare window" "$(on b)" "1"
teardown

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures check(s) failed"
fi
exit $((failures > 0))
