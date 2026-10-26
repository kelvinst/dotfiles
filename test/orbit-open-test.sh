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
  : >"$STUB_LOG"
  mkdir -p "$work/bin"

  # `<window-id> <bundle-id>` per line in STUB_WINDOWS, wherever they are.
  cat >"$work/bin/aerospace" <<'STUB'
#!/bin/sh
printf 'aerospace %s\n' "$*" >>"$STUB_LOG"
case $1 in
list-windows)
  case " $* " in
  *" --all "*) printf '%s\n' "${STUB_WINDOWS-}" | sed '/^$/d' ;;
  *) ;; # nothing on the focused workspace
  esac
  ;;
esac
STUB

  # Running apps are the bundle ids in STUB_RUNNING.
  cat >"$work/bin/lsappinfo" <<'STUB'
#!/bin/sh
id=${2#bundleid=}
case " ${STUB_RUNNING-} " in
*" $id "*) echo "ASN:0x0-0x1:" ;;
esac
STUB

  # Apps like WhatsApp and Mail can't be told to make a new window.
  cat >"$work/bin/osascript" <<'STUB'
#!/bin/sh
printf 'osascript %s\n' "$*" >>"$STUB_LOG"
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
echo "not running: launched"
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

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures check(s) failed"
fi
exit $((failures > 0))
