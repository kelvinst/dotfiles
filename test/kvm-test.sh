#!/usr/bin/env bash
# Tests for bin/kvm against stubbed m1ddc and displayplacer (dot-yll).
#
# The stubs read the monitor's input and the display arrangement from files
# in a temp dir and log every command that would change something, so no
# run touches the real monitor or displays.
set -uo pipefail

KVM=${KVM:-"$(cd "$(dirname "$0")/.." && pwd)/bin/kvm"}
SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT
failures=0

BUILTIN=37D8832A-2D66-02CA-B9F7-8F30A301B230
DELL=8E108FAB-2256-4D9F-8B91-07592B9396DB
B_SCREEN="id:$BUILTIN res:2056x1329 hz:120 color_depth:8 enabled:true scaling:on"
D_SCREEN="id:$DELL res:3840x2160 hz:60 color_depth:8 enabled:true scaling:on"
EXTENDED_LINE="displayplacer \"$B_SCREEN origin:(0,0) degree:0\" \"$D_SCREEN origin:(-893,-2160) degree:0\""
MIRRORED_LINE="displayplacer \"id:$BUILTIN+$DELL res:2056x1329 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0\""

mkdir -p "$SANDBOX/bin"
cat >"$SANDBOX/bin/m1ddc" <<EOF
#!/usr/bin/env bash
case "\$*" in
"display list") printf '[1] Unknown Display ($BUILTIN)\n[2] DELL U3223QE ($DELL)\n' ;;
"display $DELL get input")
  # One garbage read first, like the real Dell.
  if [ ! -e "$SANDBOX/read-once" ]; then touch "$SANDBOX/read-once"; echo 48750; else cat "$SANDBOX/input"; fi ;;
"display $DELL set input "*) echo "m1ddc \$*" >>"$SANDBOX/log" ;;
*) echo "unexpected m1ddc \$*" >>"$SANDBOX/log"; exit 1 ;;
esac
EOF
cat >"$SANDBOX/bin/displayplacer" <<EOF
#!/usr/bin/env bash
if [ "\$1" = list ]; then
  printf 'Persistent screen id: $BUILTIN\nType: MacBook built in screen\n\n'
  printf 'Persistent screen id: $DELL\nType: 32 inch external screen\n\n'
  cat "$SANDBOX/arrangement"
else
  printf 'displayplacer' >>"$SANDBOX/log"
  printf ' "%s"' "\$@" >>"$SANDBOX/log"
  echo >>"$SANDBOX/log"
fi
EOF
chmod +x "$SANDBOX/bin/"*
printf 'INPUT=27\nOTHER_INPUT=17\nMONITOR=U3223QE\n' >"$SANDBOX/config"

# $1 name, $2 input value the Dell reports, $3 arrangement line, $4 command,
# $5 expected log (empty for "changes nothing").
expect() {
  rm -f "$SANDBOX/log" "$SANDBOX/read-once"
  echo "$2" >"$SANDBOX/input"
  echo "$3" >"$SANDBOX/arrangement"
  PATH="$SANDBOX/bin:$PATH" KVM_CONFIG="$SANDBOX/config" \
    KVM_STATE_DIR="$SANDBOX/state" "$KVM" "$4" 2>>"$SANDBOX/stderr"
  local got
  got=$(cat "$SANDBOX/log" 2>/dev/null)
  if [ "$got" = "$5" ]; then
    echo "ok   $1"
  else
    printf 'FAIL %s\n  want: %s\n  got:  %s\n' "$1" "$5" "$got"
    failures=$((failures + 1))
  fi
}

expect "sync: shown here and extended, nothing to do" \
  6939 "$EXTENDED_LINE" sync ""

expect "sync: shown on the other Mac, mirrors the built-in onto the Dell" \
  6929 "$EXTENDED_LINE" sync "$MIRRORED_LINE"

if [ "$(cat "$SANDBOX/state/extended")" = "$EXTENDED_LINE" ]; then
  echo "ok   sync: saves the extended arrangement before mirroring"
else
  echo "FAIL sync: saved $(cat "$SANDBOX/state/extended" 2>/dev/null)"
  failures=$((failures + 1))
fi

expect "sync: back here while mirrored, restores the saved arrangement" \
  6939 "$MIRRORED_LINE" sync "$EXTENDED_LINE"

expect "sync: shown on the other Mac and mirrored, nothing to do" \
  6929 "$MIRRORED_LINE" sync ""

expect "sync: only garbage reads, changes nothing" \
  48750 "$EXTENDED_LINE" sync ""

expect "toggle: here, hands the Dell over and mirrors" \
  6939 "$EXTENDED_LINE" toggle "m1ddc display $DELL set input 17
$MIRRORED_LINE"

expect "toggle: on the other Mac, takes the Dell back and extends" \
  6929 "$MIRRORED_LINE" toggle "m1ddc display $DELL set input 27
$EXTENDED_LINE"

if [ "$failures" -gt 0 ]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "all passed"
