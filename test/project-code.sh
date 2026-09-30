#!/usr/bin/env bash
# Tests for `project-code` (dot-mrr).
#
# Every case builds throwaway git repos under a temp dir, so nothing here
# reads or writes a real repo's .claude/settings.json.
set -uo pipefail

PROJECT_CODE_BIN=${PROJECT_CODE_BIN:-"$(cd "$(dirname "$0")/.." && pwd)/bin/project-code"}
failures=0

git_q() { git -c user.name=t -c user.email=t@t "$@" >/dev/null 2>&1; }

# A fresh repo at $work/<name> with one commit; cds into it.
setup() {
  work=$(mktemp -d)
  mkdir -p "$work/$1"
  cd "$work/$1" || exit 1
  git_q init -q
  git_q commit -q --allow-empty -m init
}

teardown() {
  cd / || exit 1
  rm -rf "$work"
}

check() {
  local what=$1 got=$2 want=$3
  if [ "$got" = "$want" ]; then
    echo "  ok: $what"
  else
    echo "  FAIL: $what — got [$got], want [$want]"
    failures=$((failures + 1))
  fi
}

echo "no settings file: get exits 2 quietly"
setup dotfiles
out=$("$PROJECT_CODE_BIN" get 2>&1)
check "exit status" "$?" "2"
check "output" "$out" ""
teardown

echo "get reads an existing code"
setup dotfiles
mkdir -p .claude
printf '{"env":{"PROJECT_CODE":"dot"}}\n' >.claude/settings.json
check "code" "$("$PROJECT_CODE_BIN" get)" "dot"
check "default subcommand is get" "$("$PROJECT_CODE_BIN")" "dot"
teardown

echo "settings without the key: get exits 2"
setup dotfiles
mkdir -p .claude
printf '{"hooks":{}}\n' >.claude/settings.json
"$PROJECT_CODE_BIN" get >/dev/null 2>&1
check "exit status" "$?" "2"
teardown

echo "repo name from a worktree subdirectory is the original repo's"
setup dotfiles
git_q worktree add -q "$work/wt/session-x-123" -b wt
mkdir -p "$work/wt/session-x-123/sub"
cd "$work/wt/session-x-123/sub" || exit 1
check "repo" "$("$PROJECT_CODE_BIN" repo)" "dotfiles"
check "propose" "$("$PROJECT_CODE_BIN" propose)" "dot"
teardown

echo "proposals"
for pair in dotfiles:dot obsidian-kingdone-chapel:okc kix-agents:kix \
  Stingdom:sti StingDomApp:sda my_big.repo-name:mbr; do
  setup "${pair%%:*}"
  check "${pair%%:*}" "$("$PROJECT_CODE_BIN" propose)" "${pair##*:}"
  teardown
done

echo "set creates .claude/settings.json at the worktree root"
setup dotfiles
mkdir -p sub
(cd sub && "$PROJECT_CODE_BIN" set dot)
check "exit status" "$?" "0"
check "written" "$(jq -r .env.PROJECT_CODE .claude/settings.json)" "dot"
check "not in sub" "$([ -e sub/.claude ] && echo yes || echo no)" "no"
teardown

echo "set keeps every other key"
setup dotfiles
mkdir -p .claude
printf '{"hooks":{"SessionStart":[]},"env":{"FOO":"1"}}\n' >.claude/settings.json
"$PROJECT_CODE_BIN" set kxa
check "code" "$(jq -r .env.PROJECT_CODE .claude/settings.json)" "kxa"
check "other env" "$(jq -r .env.FOO .claude/settings.json)" "1"
check "hooks" "$(jq -c .hooks .claude/settings.json)" '{"SessionStart":[]}'
teardown

echo "set rejects invalid codes and leaves the file alone"
setup dotfiles
mkdir -p .claude
printf '{"env":{"PROJECT_CODE":"dot"}}\n' >.claude/settings.json
for bad in DOT dots d-t "" do; do
  "$PROJECT_CODE_BIN" set "$bad" >/dev/null 2>&1
  check "reject [$bad]" "$?" "1"
done
check "untouched" "$(jq -r .env.PROJECT_CODE .claude/settings.json)" "dot"
teardown

echo "outside a git repo: exit 1"
work=$(mktemp -d)
cd "$work" || exit 1
"$PROJECT_CODE_BIN" get >/dev/null 2>&1
check "exit status" "$?" "1"
teardown

if [ "$failures" -eq 0 ]; then
  echo "all passed"
else
  echo "$failures check(s) failed"
fi
exit $((failures > 0))
