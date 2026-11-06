-- Hands the Dell U3223QE between this Mac and the other one on its KVM.
-- cmd-ctrl-d gives the monitor away when this Mac has it, and takes it back
-- when it doesn't.
--
-- Switching the input alone isn't enough: a Mac the monitor is no longer
-- showing keeps the Dell attached, and Universal Control lays it out as
-- "Dell + built-in", so the cursor has to cross a Dell nobody can see to
-- reach the built-in screen. Giving the monitor away detaches it here too
-- (BetterDisplay), so Universal Control only sees the built-in.
local M = {}

local HOTKEY_MODS = { cmd = true, ctrl = true }
local HOTKEY_KEY = "d"

local DELL_UUID = "8E108FAB-2256-4D9F-8B91-07592B9396DB"
local DELL_NAME = "DELL U3223QE"

-- VCP 0x60 input codes. This Mac is on the Dell's USB-C, the other one on
-- HDMI 1. Reading 0x60 back is no help in telling them apart: about half
-- the reads come back as garbage (48750).
local INPUT_HERE = 27
local INPUT_OTHER = 17

-- Full paths: Hammerspoon inherits the bare launchd PATH.
local M1DDC = "/opt/homebrew/bin/m1ddc"
local BETTERDISPLAY = "/opt/homebrew/bin/betterdisplaycli"

-- A reattached Dell takes a moment (~0.1s) to show up again before m1ddc
-- can address it. Retried rather than slept on, so the input switches the
-- moment it can; MAX_TRIES caps the wait at 5s.
local RETRY_SECONDS = 0.1
local MAX_TRIES = 50

-- The built-in stays the main display, Dell or not. A reattach usually
-- leaves it main anyway; this makes sure.
local BUILTIN_NAME = "Built-in Display"

-- Held on the module table: a collected task never finishes its chain.
local function run(script)
  M.task = hs.task.new("/bin/sh", function(code, _, stderr)
    if code ~= 0 then
      hs.printf("kvm: exited %d %s", code, stderr or "")
      hs.alert.show("KVM switch failed, see the console")
    end
  end, { "-c", script })
  M.task:start()
end

local function giveAway()
  -- Input first: m1ddc can't reach the Dell once it's detached.
  run(
    string.format(
      "%s display %s set input %d && %s set --name=%q --connected=off",
      M1DDC,
      DELL_UUID,
      INPUT_OTHER,
      BETTERDISPLAY,
      DELL_NAME
    )
  )
end

local function takeBack()
  -- Input before the main-display fix: the switch is what's waited on.
  run(
    string.format(
      "%s set --name=%q --connected=on || exit 1; i=0; "
        .. "until %s display %s set input %d >/dev/null 2>&1; do "
        .. "i=$((i + 1)); [ $i -ge %d ] && exit 1; sleep %s; done; "
        .. "%s set --name=%q --main=on",
      BETTERDISPLAY,
      DELL_NAME,
      M1DDC,
      DELL_UUID,
      INPUT_HERE,
      MAX_TRIES,
      RETRY_SECONDS,
      BETTERDISPLAY,
      BUILTIN_NAME
    )
  )
end

function M.toggle()
  if M.task and M.task:isRunning() then
    return
  end
  if hs.screen.find(DELL_UUID) then
    giveAway()
  else
    takeBack()
  end
end

-- An event tap rather than hs.hotkey, for the reason windowhints.lua gives.
local function onTrigger(event)
  if hs.keycodes.map[event:getKeyCode()] ~= HOTKEY_KEY then
    return false
  end
  local flags = event:getFlags()
  for _, mod in ipairs({ "cmd", "alt", "shift", "ctrl" }) do
    if (flags[mod] or false) ~= (HOTKEY_MODS[mod] or false) then
      return false
    end
  end
  M.toggle()
  return true
end

M.trigger = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, onTrigger)
M.trigger:start()

return M
