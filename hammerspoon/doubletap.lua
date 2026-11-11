-- Double-tap a left modifier to send a key (dot-p45): Control -> Return,
-- Command -> Space, Option -> Backspace. They stand in for the ErgoDox
-- right-thumb keys while the right hand is on the mouse. This used to live
-- in Karabiner; Hammerspoon does it with an eventtap, so it also works on
-- a Mac where Karabiner's driver can't be installed.
--
-- Both presses are ordinary modifier presses: nothing is swallowed, so a
-- tap-and-hold is just the modifier held, as if this module weren't here.
-- The key goes out on the second release, and only when both presses were
-- quick taps (each under WINDOW seconds, and the second press under WINDOW
-- after the first release) with nothing else pressed in between. Any other
-- key, modifier or mouse button disarms it, so chords like cmd-c, cmd-c or
-- cmd-click, cmd-click stay chords. Other modifiers held at the second
-- release carry through: hold Shift and double-tap Control for
-- Shift+Return. The key is a single stroke; it doesn't repeat.
--
-- Tap, then press and hold past HOLD seconds with nothing else pressed,
-- and it sends the modifier plus the key while still held: Ctrl+Return,
-- Cmd+Space, Option+Backspace. Releasing after that sends nothing more.
local M = {}

M.WINDOW = 0.3
M.HOLD = 0.5

-- Device-dependent bits of the raw event flags (NX_DEVICEL*KEYMASK), one
-- per physical left modifier. Matching on these rather than key codes
-- also catches Caps Lock remapped to Control (the hidutil LaunchAgent).
M.RULES = {
  { mask = 0x00000001, key = "return" },
  { mask = 0x00000008, key = "space" },
  { mask = 0x00000020, key = "delete" },
}

-- Every device-dependent modifier bit: left/right Control, Shift, Option,
-- Command. A change in any of them that isn't a rule's disarms.
local DEVICE_BITS = 0x0000207f

-- The pure state machine, kept free of `hs` so make test can drive it.
-- `flags(raw, mods, now)` takes a flagsChanged event's raw flags and its
-- modifier table; `other()` is any key or mouse button going down.
-- `flags` returns nil; { key = <key name>, mods = <modifier table> } when
-- the event completes a double-tap: send that keystroke; or { wait =
-- <seconds> } on the second press: call `hold(now)` after that long, and
-- send what it returns, if anything. The event itself always passes
-- through.
function M.machine(rules, window, holdFor)
  rules = rules or M.RULES
  window = window or M.WINDOW
  holdFor = holdFor or M.HOLD
  -- `step` is how far the current rule's sequence got: "down1" (first
  -- press), "up1" (released, armed), "down2" (second press), "fired" (the
  -- hold sent its keystroke). `at` is when it got there.
  local m = { prev = 0, rule = nil, step = nil, at = 0 }

  local function reset()
    m.rule, m.step = nil, nil
  end

  function m.other()
    reset()
  end

  -- A timer from an earlier second press finds a later `at` (or another
  -- step) and sends nothing.
  function m.hold(now)
    if m.step == "down2" and now - m.at >= holdFor then
      m.step = "fired"
      return { key = m.rule.key, mods = m.holdMods }
    end
    return nil
  end

  function m.flags(raw, mods, now)
    raw = raw & DEVICE_BITS
    local changed = raw ~ m.prev
    m.prev = raw
    local rule
    for _, r in ipairs(rules) do
      if changed == r.mask then
        rule = r
      end
    end
    if not rule then
      if changed ~= 0 then
        reset()
      end
      return nil
    end

    local down = raw & rule.mask ~= 0
    local quick = m.rule == rule and now - m.at <= window
    if down then
      if quick and m.step == "up1" then
        m.step, m.at, m.holdMods = "down2", now, mods or {}
        return { wait = holdFor }
      else
        m.rule, m.step, m.at = rule, "down1", now
      end
      return nil
    end

    if quick and m.step == "down1" then
      m.step, m.at = "up1", now
      return nil
    end
    local done = quick and m.step == "down2"
    reset()
    if done then
      return { key = rule.key, mods = mods or {} }
    end
    return nil
  end

  return m
end

-- newKeyEvent wants a list of names ({ "shift" }); a { shift = true } set
-- reads as no modifiers, which once dropped Shift from Shift+Return.
local function stroke(key, mods)
  local list = {}
  for name in pairs(mods) do
    list[#list + 1] = name
  end
  hs.eventtap.event.newKeyEvent(list, key, true):post()
  hs.eventtap.event.newKeyEvent(list, key, false):post()
end

function M.start()
  local types = hs.eventtap.event.types
  M.state = M.machine()

  -- Held on the module table: a collected timer never fires.
  local function waitHold(seconds)
    M.holdTimer = hs.timer.doAfter(seconds, function()
      local a = M.state.hold(hs.timer.secondsSinceEpoch())
      if a then
        stroke(a.key, a.mods)
      end
    end)
  end

  M.tap = hs.eventtap.new({
    types.flagsChanged,
    types.keyDown,
    types.leftMouseDown,
    types.rightMouseDown,
    types.otherMouseDown,
  }, function(e)
    if e:getType() ~= types.flagsChanged then
      M.state.other()
      return false
    end
    local a =
      M.state.flags(e:rawFlags(), e:getFlags(), hs.timer.secondsSinceEpoch())
    if a and a.wait then
      waitHold(a.wait)
    elseif a then
      -- After the release has gone through, so the keystroke doesn't
      -- reach the app before the modifier's key-up.
      hs.timer.doAfter(0, function()
        stroke(a.key, a.mods)
      end)
    end
    return false
  end)
  M.tap:start()

  -- macOS disables a tap whose callback ever runs too long; without this
  -- the double-taps would quietly stop until the next reload.
  M.watchdog = hs.timer.doEvery(5, function()
    if not M.tap:isEnabled() then
      M.tap:start()
    end
  end)
  return M
end

return M
