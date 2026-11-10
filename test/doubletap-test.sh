#!/usr/bin/env bash
# Regression tests for hammerspoon/doubletap.lua (dot-p45).
#
# Drives the module's pure state machine with plain Lua, no Hammerspoon:
# the raw flag numbers are the device-dependent masks a flagsChanged event
# carries (0x1 left Control, 0x8 left Command, 0x20 left Option, 0x2 left
# Shift, 0x10 right Command).
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
  if a.wait then
    return "wait " .. a.wait
  end
  local mods = {}
  for k in pairs(a.mods) do
    mods[#mods + 1] = k
  end
  table.sort(mods)
  return a.key .. (#mods > 0 and (" +" .. table.concat(mods, "+")) or "")
end

-- steps: { "f", raw, mods, t } for flagsChanged, { "o" } for another key,
-- { "h", t } for the hold timer firing.
-- want: what the last step returns.
local function case(name, steps, want)
  local m = dt.machine()
  local got
  for _, s in ipairs(steps) do
    if s[1] == "o" then
      m.other()
      got = nil
    elseif s[1] == "h" then
      got = m.hold(s[2])
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
local shift = { shift = true }

-- tap(mask, mods, t): press at t, release at t + 0.05.
local function tap(mask, mods, t, base, baseMods)
  base, baseMods = base or 0, baseMods or {}
  local down = {}
  for k, v in pairs(baseMods) do
    down[k] = v
  end
  for k, v in pairs(mods) do
    down[k] = v
  end
  return { "f", base | mask, down, t }, { "f", base, baseMods, t + 0.05 }
end

local function seq(...)
  local out = {}
  for _, group in ipairs({ ... }) do
    for _, s in ipairs(group) do
      out[#out + 1] = s
    end
  end
  return out
end

local function T(...)
  return { tap(...) }
end

case("double-tap Control sends Return", seq(T(C, ctrl, 0), T(C, ctrl, 0.2)),
  "return")
case("double-tap Command sends Space", seq(T(CMD, cmd, 0), T(CMD, cmd, 0.2)),
  "space")
case("double-tap Option sends Backspace",
  seq(T(OPT, alt, 0), T(OPT, alt, 0.2)), "delete")
case("the second press only starts the hold timer", {
  { "f", C, ctrl, 0 }, { "f", 0, {}, 0.05 }, { "f", C, ctrl, 0.2 },
}, "wait 0.5")
case("tap then hold sends Ctrl+Return while held", {
  { "f", C, ctrl, 0 }, { "f", 0, {}, 0.05 }, { "f", C, ctrl, 0.2 },
  { "h", 0.7 },
}, "return +ctrl")
case("tap then hold sends Cmd+Space", {
  { "f", CMD, cmd, 0 }, { "f", 0, {}, 0.05 }, { "f", CMD, cmd, 0.2 },
  { "h", 0.7 },
}, "space +cmd")
case("tap then hold sends Option+Backspace", {
  { "f", OPT, alt, 0 }, { "f", 0, {}, 0.05 }, { "f", OPT, alt, 0.2 },
  { "h", 0.7 },
}, "delete +alt")
case("releasing after the hold fired sends nothing", {
  { "f", C, ctrl, 0 }, { "f", 0, {}, 0.05 }, { "f", C, ctrl, 0.2 },
  { "h", 0.7 }, { "f", 0, {}, 0.9 },
}, "pass")
case("a key during the hold cancels it (tap, then ctrl-a)", {
  { "f", C, ctrl, 0 }, { "f", 0, {}, 0.05 }, { "f", C, ctrl, 0.2 },
  { "o" }, { "h", 0.7 },
}, "pass")
case("released before the hold timer: no hold", {
  { "f", C, ctrl, 0 }, { "f", 0, {}, 0.05 }, { "f", C, ctrl, 0.2 },
  { "f", 0, {}, 0.4 }, { "h", 0.7 },
}, "pass")
case("a stale timer from an earlier press does nothing", seq(
  T(C, ctrl, 0), T(C, ctrl, 0.2),
  { { "f", C, ctrl, 0.4 }, { "f", 0, {}, 0.45 }, { "f", C, ctrl, 0.6 },
    { "h", 0.7 } }
), "pass")
case("tap then tap-and-hold is just a held modifier", {
  { "f", C, ctrl, 0 }, { "f", 0, {}, 0.05 }, { "f", C, ctrl, 0.2 },
  { "f", 0, {}, 0.8 },
}, "pass")
case("a long first press doesn't arm", {
  { "f", C, ctrl, 0 }, { "f", 0, {}, 0.5 }, { "f", C, ctrl, 0.6 },
  { "f", 0, {}, 0.65 },
}, "pass")
case("held Shift carries through: Shift+Return", seq(
  { { "f", SH, shift, 0 } },
  T(C, ctrl, 0.1, SH, shift), T(C, ctrl, 0.3, SH, shift)
), "return +shift")
case("held Command and Option carry through", seq(
  { { "f", CMD | OPT, { cmd = true, alt = true }, 0 } },
  T(C, ctrl, 0.1, CMD | OPT, { cmd = true, alt = true }),
  T(C, ctrl, 0.3, CMD | OPT, { cmd = true, alt = true })
), "return +alt+cmd")
case("too slow between taps is just a modifier",
  seq(T(CMD, cmd, 0), T(CMD, cmd, 0.5)), "pass")
case("a key between taps disarms (cmd-c, cmd-c)",
  seq(T(CMD, cmd, 0), { { "o" } }, T(CMD, cmd, 0.2)), "pass")
case("a key while the first is held disarms", seq(
  { { "f", CMD, cmd, 0 }, { "o" }, { "f", 0, {}, 0.05 } }, T(CMD, cmd, 0.2)
), "pass")
case("a key while the second is held disarms", seq(T(CMD, cmd, 0), {
  { "f", CMD, cmd, 0.2 }, { "o" }, { "f", 0, {}, 0.25 },
}), "pass")
case("a different modifier between taps disarms",
  seq(T(CMD, cmd, 0), T(OPT, alt, 0.1), T(CMD, cmd, 0.2)), "pass")
case("right Command between taps disarms",
  seq(T(C, ctrl, 0), T(0x10, cmd, 0.1), T(C, ctrl, 0.2)), "pass")
case("double-tap Shift does nothing",
  seq(T(SH, shift, 0), T(SH, shift, 0.2)), "pass")
case("right Command is left alone",
  seq(T(0x10, cmd, 0), T(0x10, cmd, 0.2)), "pass")
case("a third tap is a plain modifier",
  seq(T(C, ctrl, 0), T(C, ctrl, 0.2), T(C, ctrl, 0.4)), "pass")
case("four taps: the second pair fires again",
  seq(T(C, ctrl, 0), T(C, ctrl, 0.2), T(C, ctrl, 0.4), T(C, ctrl, 0.6)),
  "return")
case("non-device flag bits are ignored", {
  { "f", 0x100000 | CMD, cmd, 0 }, { "f", 0x100000, {}, 0.05 },
  { "f", 0x100000 | CMD, cmd, 0.2 }, { "f", 0x100000, {}, 0.25 },
}, "space")

os.exit(failures == 0 and 0 or 1)
EOF
