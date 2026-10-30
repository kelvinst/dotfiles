#!/usr/bin/env bash
# Regression tests for `orbit open` (dot-bt5).
#
# Stubs on PATH stand in for aerospace, osascript, lsappinfo and open, and
# record what orbit asks of them, so a run never launches or focuses a
# real app.
set -uo pipefail

ORBIT=${ORBIT:-"$(cd "$(dirname "$0")/.." && pwd)/bin/orbit"}
failures=0

setup() {
  work=$(mktemp -d)
  export XDG_CACHE_HOME="$work/cache"
  export ORBIT_LOCK_DIR="$work/lock"
  export STUB_LOG="$work/calls"
  export STUB_LAUNCHED="$work/launched"
  : >"$STUB_LOG"
  : >"$STUB_LAUNCHED"
  mkdir -p "$work/bin"

  # `<window-id> <bundle-id>` per line in STUB_WINDOWS, wherever they are
  # (`<id>|<bundle-id>|<title>` for --main lookups); window ids in
  # STUB_FOCUSED are the app's windows on the focused workspace, and
  # STUB_FOCUSED_APP is the bundle id of the focused window.
  # STUB_WINDOW_WS (`<window-id> <workspace>` per line) answers --pull's
  # lookup, and STUB_WORKSPACE is the focused workspace.
  cat >"$work/bin/aerospace" <<'STUB'
#!/bin/sh
printf 'aerospace %s\n' "$*" >>"$STUB_LOG"
case $1 in
list-windows)
  case " $* " in
  *" --all "*"%{workspace}"*) printf '%s\n' "${STUB_WINDOW_WS-}" | sed '/^$/d' ;;
  *" --all "*) printf '%s\n' "${STUB_WINDOWS-}" | sed '/^$/d' ;;
  *" --focused "*) printf '%s\n' "${STUB_FOCUSED_APP-}" | sed '/^$/d' ;;
  *) printf '%s\n' "${STUB_FOCUSED-}" | sed '/^$/d' ;;
  esac
  ;;
list-workspaces) printf '%s\n' "${STUB_WORKSPACE-}" ;;
esac
STUB

  # Running apps are the bundle ids in STUB_RUNNING, plus any osascript
  # launched along the way.
  cat >"$work/bin/lsappinfo" <<'STUB'
#!/bin/sh
id=${2#bundleid=}
case " ${STUB_RUNNING-} $(cat "$STUB_LAUNCHED") " in
*" $id "*) echo "ASN:0x0-0x1:" ;;
esac
STUB

  # Apps like WhatsApp and Mail can't be told to make a new window. Like
  # the real one, `tell application id` launches the app before it fails.
  cat >"$work/bin/osascript" <<'STUB'
#!/bin/sh
printf 'osascript %s\n' "$*" >>"$STUB_LOG"
printf '%s\n' "$*" | sed -n 's/.*application id "\([^"]*\)".*/\1/p' >>"$STUB_LAUNCHED"
exit 1
STUB

  cat >"$work/bin/open" <<'STUB'
#!/bin/sh
printf 'open %s\n' "$*" >>"$STUB_LOG"
STUB

  chmod +x "$work/bin/"*
  PATH="$work/bin:$PATH"
  export PATH
}

teardown() { rm -rf "$work"; }

opens() { grep '^open ' "$STUB_LOG"; }

check() {
  local what=$1 got=$2 want=$3
  if [ "$got" = "$want" ]; then
    echo "  ok: $what"
  else
    echo "  FAIL: $what — got [$got], want [$want]"
    failures=$((failures + 1))
  fi
}

# --- dot-bt5 -------------------------------------------------------------
# A single-instance app running with its last window closed has no window
# for aerospace to find. `open -nb` then asked for a second instance:
# WhatsApp refused with a dialog, Mail started another process. A plain
# reopen brings back the main window instead.
echo "running without windows, -g: reopened, no second instance"
setup
STUB_RUNNING=net.whatsapp.WhatsApp "$ORBIT" open -g net.whatsapp.WhatsApp
check "exit status" "$?" "0"
check "open call" "$(opens)" "open -b net.whatsapp.WhatsApp"
teardown

echo "running without windows, focused workspace: reopened"
setup
STUB_RUNNING=com.apple.mail "$ORBIT" open com.apple.mail
check "open call" "$(opens)" "open -b com.apple.mail"
teardown

# --- what the fix must keep ----------------------------------------------
# AppleScript's `tell application id` launched a closed app before it
# failed, so the fallback found it running and asked for a second copy
# on top: two Mail processes a second apart.
echo "not running: launched once"
setup
"$ORBIT" open -g net.whatsapp.WhatsApp
check "open call" "$(opens)" "open -b net.whatsapp.WhatsApp"
teardown

echo "window elsewhere, focused workspace only: second instance"
setup
STUB_RUNNING=com.anthropic.claudefordesktop \
  STUB_WINDOWS="7 com.anthropic.claudefordesktop" \
  "$ORBIT" open com.anthropic.claudefordesktop
check "open call" "$(opens)" "open -nb com.anthropic.claudefordesktop"
teardown

echo "window elsewhere, -g: focused, nothing opened"
setup
STUB_RUNNING=net.whatsapp.WhatsApp STUB_WINDOWS="9 net.whatsapp.WhatsApp" \
  "$ORBIT" open -g net.whatsapp.WhatsApp
check "open call" "$(opens)" ""
check "focused" "$(grep -c '^aerospace focus --window-id 9$' "$STUB_LOG")" "1"
teardown

# --- --main ----------------------------------------------------------------
# cmd-ctrl-c: a Claude window on this workspace wins; else the main window
# (titled "Claude") gets focus, pulled over here with --pull.
CLAUDE=com.anthropic.claudefordesktop
echo "--main, window on focused workspace: focused there"
setup
STUB_RUNNING=$CLAUDE STUB_FOCUSED=5 \
  STUB_WINDOWS="3|$CLAUDE|Claude" "$ORBIT" open -m Claude $CLAUDE
check "focused" "$(grep -c '^aerospace focus --window-id 5$' "$STUB_LOG")" "1"
check "nothing moved" "$(grep -c move-node "$STUB_LOG")" "0"
teardown

echo "--main, none on focused workspace: main window focused, not moved"
setup
STUB_RUNNING=$CLAUDE \
  STUB_WINDOWS="$(printf '4|%s|chat\n3|%s|Claude' $CLAUDE $CLAUDE)" \
  "$ORBIT" open -m Claude $CLAUDE
check "focused" "$(grep -c '^aerospace focus --window-id 3$' "$STUB_LOG")" "1"
check "nothing moved" "$(grep -c move-node "$STUB_LOG")" "0"
check "open call" "$(opens)" ""
teardown

echo "--main, no window has the title: oldest window focused"
setup
STUB_RUNNING=$CLAUDE \
  STUB_WINDOWS="$(printf '8|%s|chat a\n6|%s|chat b' $CLAUDE $CLAUDE)" \
  "$ORBIT" open -m Claude $CLAUDE
check "focused" "$(grep -c '^aerospace focus --window-id 6$' "$STUB_LOG")" "1"
check "open call" "$(opens)" ""
teardown

echo "--main, the app's window already focused: main window focused"
setup
STUB_RUNNING=$CLAUDE STUB_FOCUSED=5 STUB_FOCUSED_APP=$CLAUDE \
  STUB_WINDOWS="$(printf '5|%s|chat\n3|%s|Claude' $CLAUDE $CLAUDE)" \
  "$ORBIT" open -m Claude $CLAUDE
check "focused" "$(grep -c '^aerospace focus --window-id 3$' "$STUB_LOG")" "1"
check "nothing moved" "$(grep -c move-node "$STUB_LOG")" "0"
teardown

echo "--main --pull, none on focused workspace: main window pulled here"
setup
STUB_RUNNING=$CLAUDE STUB_WORKSPACE=2 STUB_WINDOW_WS='3 0' \
  STUB_WINDOWS="$(printf '4|%s|chat\n3|%s|Claude' $CLAUDE $CLAUDE)" \
  "$ORBIT" open -p -m Claude $CLAUDE
check "pulled" "$(grep -c '^aerospace move-node-to-workspace --window-id 3 2$' "$STUB_LOG")" "1"
check "focused" "$(grep -c '^aerospace focus --window-id 3$' "$STUB_LOG")" "1"
check "open call" "$(opens)" ""
teardown

echo "--main --pull, window on focused workspace: focused, nothing pulled"
setup
STUB_RUNNING=$CLAUDE STUB_FOCUSED=5 STUB_WORKSPACE=2 STUB_WINDOW_WS='5 2' \
  STUB_WINDOWS="3|$CLAUDE|Claude" "$ORBIT" open -p -m Claude $CLAUDE
check "focused" "$(grep -c '^aerospace focus --window-id 5$' "$STUB_LOG")" "1"
check "nothing moved" "$(grep -c move-node "$STUB_LOG")" "0"
teardown

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures check(s) failed"
fi
exit $((failures > 0))
