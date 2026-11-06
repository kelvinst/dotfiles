-- cmd-ctrl-d hands the Dell U3223QE to the other Mac on its KVM, or takes
-- it back. `kvm toggle` (bin/kvm) does the work: it switches the input and
-- mirrors or extends this Mac's displays, and the `kvm watch` agent on the
-- other Mac does its half when it sees the input change.
local M = {}

local HOTKEY_MODS = { cmd = true, ctrl = true }
local HOTKEY_KEY = "d"

-- Hammerspoon inherits the bare launchd PATH, and kvm needs m1ddc and
-- displayplacer from Homebrew.
local TOGGLE = 'PATH="/opt/homebrew/bin:$PATH" "$HOME/.local/bin/kvm" toggle'

function M.toggle()
  -- Held on the module table: a collected task never calls back.
  if M.task and M.task:isRunning() then
    return
  end
  M.task = hs.task.new("/bin/sh", function(code, _, stderr)
    if code ~= 0 then
      hs.printf("kvm: exited %d %s", code, stderr or "")
      hs.alert.show("KVM switch failed, see the console")
    end
  end, { "-c", TOGGLE })
  M.task:start()
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
