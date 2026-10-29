#!/usr/bin/env bash
# Regression tests for script/check (dot-5de).
#
# Each case stages one line in a throwaway repo and runs the check on it,
# so the .gitleaks.toml rules are pinned: what they catch and what they spare.
set -uo pipefail

CHECK=${CHECK:-"$(cd "$(dirname "$0")/.." && pwd)/script/check"}
failures=0
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

expect() {
  local want=$1 line=$2 repo got
  repo=$(mktemp -d "$work/repo.XXXX")
  git -C "$repo" init -q
  printf '%s\n' "$line" >"$repo/f"
  git -C "$repo" add f
  if (cd "$repo" && "$CHECK" --staged >/dev/null 2>&1); then got=pass; else got=block; fi
  if [ "$got" = "$want" ]; then
    echo "ok   $want: $line"
  else
    echo "FAIL $line"
    echo "     want: $want"
    echo "     got:  $got"
    failures=$((failures + 1))
  fi
}

expect block 'url=https://mybox.tail1a2b.ts.net/x'
expect block 'url=https://MyBox.Tail1a2b.ts.net/x'
expect block 'ip=100.101.3.4'
expect block 'ip=fd7a:115c:a1e0::1'
expect block 'key=tskey-auth-kAbC123CNTRL-xYz789abcdefGHIJ'
expect pass 'host=machine.<tailnet>.ts.net'
expect pass 'ip=100.200.1.1'
expect pass 'ip=192.168.1.10'

[ "$failures" -eq 0 ] || { echo "$failures failure(s)"; exit 1; }
