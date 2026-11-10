#!/usr/bin/env bash
# Regression tests for hammerspoon/doubletap.lua (dot-p45).
#
# Drives the module's pure state machine with plain Lua, no Hammerspoon:
# the raw flag numbers are the device-dependent masks a flagsChanged event
# carries (0x1 left Control, 0x8 left Command, 0x20 left Option, 0x2 left
# Shift).
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LUA=${LUA:-lua}

"$LUA" - "$ROOT/hammerspoon/doubletap.lua" <<'EOF'
local dt = dofile(arg[1])
local failures = 0

local function describe(a)
  if not a then
    return "pass"
  end
  local mods = {}
  for k in pairs(a.mods) do
    mods[#mods + 1] = k
  end
  table.sort(mods)
  return (a.down and "down " or "up ")
    .. a.key
    .. (#mods > 0 and (" +" .. table.concat(mods, "+")) or "")
end

-- steps: { "f", raw, mods, t } for flagsChanged, { "o" } for another key.
-- want: what the last step should return.
local function case(name, steps, want)
  local m = dt.machine()
  local got
  for _, s in ipairs(steps) do
    if s[1] == "o" then
      m.other()
      got = nil
    else
      got = m.flags(s[2], s[3] or {}, s[4])
    end
  end
  got = describe(got)
  if got == want then
    print("ok   " .. name)
  else
    print("FAIL " .. name .. "\n     want: " .. want .. "\n     got:  " .. got)
    failures = failures + 1
  end
end

local C, CMD, OPT, SH = 0x1, 0x8, 0x20, 0x2
local ctrl, cmd, alt = { ctrl = true }, { cmd = true }, { alt = true }

case("double-tap Control sends Return", {
  { "f", C, ctrl, 0 }, { "f", 0, {}, 0.1 }, { "f", C, ctrl, 0.2 },
}, "down return")
case("double-tap Command sends Space", {
  { "f", CMD, cmd, 0 }, { "f", 0, {}, 0.1 }, { "f", CMD, cmd, 0.2 },
}, "down space")
case("double-tap Option sends Backspace", {
  { "f", OPT, alt, 0 }, { "f", 0, {}, 0.1 }, { "f", OPT, alt, 0.2 },
}, "down delete")
case("releasing the second tap releases the key", {
  { "f", C, ctrl, 0 }, { "f", 0, {}, 0.1 }, { "f", C, ctrl, 0.2 },
  { "f", 0, {}, 0.3 },
}, "up return")
case("held Shift carries through: Shift+Return", {
  { "f", SH, { shift = true }, 0 },
  { "f", SH | C, { shift = true, ctrl = true }, 0.1 },
  { "f", SH, { shift = true }, 0.15 },
  { "f", SH | C, { shift = true, ctrl = true }, 0.2 },
}, "down return +shift")
case("window counts from the release", {
  { "f", CMD, cmd, 0 }, { "f", 0, {}, 1.0 }, { "f", CMD, cmd, 1.25 },
}, "down space")
case("too slow is just a modifier", {
  { "f", CMD, cmd, 0 }, { "f", 0, {}, 0.1 }, { "f", CMD, cmd, 0.5 },
}, "pass")
case("a key between taps disarms (cmd-c, cmd-c)", {
  { "f", CMD, cmd, 0 }, { "f", 0, {}, 0.1 }, { "o" },
  { "f", CMD, cmd, 0.2 },
}, "pass")
case("a key while held disarms (cmd-c then cmd)", {
  { "f", CMD, cmd, 0 }, { "o" }, { "f", 0, {}, 0.1 },
  { "f", CMD, cmd, 0.2 },
}, "pass")
case("a different modifier between taps disarms", {
  { "f", CMD, cmd, 0 }, { "f", 0, {}, 0.05 }, { "f", OPT, alt, 0.1 },
  { "f", 0, {}, 0.15 }, { "f", CMD, cmd, 0.2 },
}, "pass")
case("double-tap Shift does nothing", {
  { "f", SH, {}, 0 }, { "f", 0, {}, 0.1 }, { "f", SH, {}, 0.2 },
}, "pass")
case("third tap after a double-tap is a plain modifier", {
  { "f", C, ctrl, 0 }, { "f", 0, {}, 0.1 }, { "f", C, ctrl, 0.2 },
  { "f", 0, {}, 0.25 }, { "f", C, ctrl, 0.3 },
}, "pass")
case("right Command (0x10) is left alone", {
  { "f", 0x10, cmd, 0 }, { "f", 0, {}, 0.1 }, { "f", 0x10, cmd, 0.2 },
}, "pass")
case("right Command between taps disarms", {
  { "f", C, ctrl, 0 }, { "f", 0, {}, 0.05 }, { "f", 0x10, cmd, 0.1 },
  { "f", 0, {}, 0.15 }, { "f", C, ctrl, 0.2 },
}, "pass")
case("held Command and Option carry through", {
  { "f", CMD | OPT, { cmd = true, alt = true }, 0 },
  { "f", CMD | OPT | C, { cmd = true, alt = true, ctrl = true }, 0.1 },
  { "f", CMD | OPT, { cmd = true, alt = true }, 0.15 },
  { "f", CMD | OPT | C, { cmd = true, alt = true, ctrl = true }, 0.2 },
}, "down return +alt+cmd")
case("non-device flag bits are ignored", {
  { "f", 0x100000 | CMD, cmd, 0 }, { "f", 0, {}, 0.1 },
  { "f", 0x100000 | CMD, cmd, 0.2 },
}, "down space")

os.exit(failures == 0 and 0 or 1)
EOF
