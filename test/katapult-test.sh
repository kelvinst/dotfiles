#!/usr/bin/env bash
# Regression tests for katapult (dot-7h6).
#
# katapult only prints links, so the checks compare its output.
set -uo pipefail

KATAPULT=${KATAPULT:-"$(cd "$(dirname "$0")/.." && pwd)/bin/katapult"}
failures=0

expect() {
  local want=$1 got
  shift
  got=$("$KATAPULT" "$@")
  if [ "$got" = "$want" ]; then
    echo "ok   katapult $*"
  else
    echo "FAIL katapult $*"
    echo "     want: $want"
    echo "     got:  $got"
    failures=$((failures + 1))
  fi
}

K=https://kelvinst.github.io/katapult/#

expect "${K}obsidian%3A%2F%2Fopen%3Fvault%3DStingdom%26file%3DRoutines%26paneType%3Dtab" \
  'obsidian://open?vault=Stingdom&file=Routines&paneType=tab'
expect "[Routines](${K}obsidian%3A%2F%2Fopen%3Fvault%3DStingdom%26file%3DRoutines%26paneType%3Dtab)" \
  note Stingdom Routines.md
expect "[Minha nota › Seção](${K}obsidian%3A%2F%2Fopen%3Fvault%3DStingdom%26file%3DMinha%2520nota%2523Se%25C3%25A7%25C3%25A3o%26paneType%3Dtab)" \
  note Stingdom 'Minha nota#Seção'
expect "$(printf '%s\n%s' "${K}x-a%3A%2F%2F1" "${K}x-b%3A%2F%2F2")" x-a://1 x-b://2

if "$KATAPULT" >/dev/null 2>&1; then
  echo "FAIL katapult with no args exits 0"
  failures=$((failures + 1))
else
  echo "ok   katapult with no args fails"
fi

if [ "$failures" -gt 0 ]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "all passed"
