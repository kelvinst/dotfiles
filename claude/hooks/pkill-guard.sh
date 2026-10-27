#!/bin/bash
# PreToolUse hook (Bash): deny pkill/killall calls whose pattern can reach
# unrelated apps. `pkill -f cat` matches "/Applications/" in every app's path
# and once killed Obsidian, Hammerspoon, Raycast and AeroSpace at once
# (dot-9gg). pkill must name an exact process (-x) or anchor its full-path
# pattern (-f '^/...'); killall must not use a regex (-m).

/usr/bin/python3 -c '
import json, os, shlex, sys

cmd = json.load(sys.stdin).get("tool_input", {}).get("command", "")
try:
    lex = shlex.shlex(cmd, posix=True, punctuation_chars=";&|()`$<>")
    lex.whitespace_split = True
    tokens = list(lex)
except ValueError:
    tokens = cmd.split()

# pkill options that take a value (macOS pkill(1)).
VALUED = set("FGgJMNPstUu")


def segments(tokens):
    seg = []
    for t in tokens:
        if t and set(t) <= set(";&|()`$<>"):
            if seg:
                yield seg
            seg = []
        else:
            seg.append(t)
    if seg:
        yield seg


# -9, -SIGTERM, -TERM: a signal, not a cluster of single-letter flags.
def is_signal(body):
    return body.isdigit() or body.startswith("SIG") or (
        len(body) >= 3 and body.isalnum() and body.isupper()
    )


def check_pkill(args):
    exact = full = False
    pattern = None
    i = 0
    while i < len(args):
        a = args[i]
        if a == "--":
            pattern = args[i + 1] if i + 1 < len(args) else None
            break
        if a.startswith("-") and len(a) > 1 and not is_signal(a[1:]):
            for j, c in enumerate(a[1:]):
                if c == "x":
                    exact = True
                elif c == "f":
                    full = True
                elif c in VALUED:
                    if j == len(a) - 2:
                        i += 1
                    break
        elif not a.startswith("-"):
            pattern = a
            break
        i += 1
    if pattern is None or exact:
        return None
    if full and pattern.startswith("^/"):
        return None
    return (
        f"pkill {pattern!r} matches any process whose "
        + ("command line" if full else "name")
        + " merely contains it, so it can kill unrelated apps "
        "(pkill -f cat matches every /Applications path). "
        "Use pkill -x <exact name>, pkill -f with a pattern anchored to the "
        "full path (^/Applications/Foo.app/), or kill <pid>."
    )


def check_killall(args):
    for a in args:
        if a == "--":
            break
        if a.startswith("-") and "m" in a[1:] and not a[1:].isdigit():
            return (
                "killall -m treats the name as a regex and can kill unrelated "
                "apps. Use killall <exact name> or kill <pid>."
            )
    return None


for seg in segments(tokens):
    while seg and ("=" in seg[0] or seg[0] in ("sudo", "command", "exec", "env")):
        seg = seg[1:]
    if not seg:
        continue
    name = os.path.basename(seg[0])
    reason = None
    if name == "pkill":
        reason = check_pkill(seg[1:])
    elif name == "killall":
        reason = check_killall(seg[1:])
    if reason:
        print(json.dumps({"hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }}))
        break
'
exit 0
