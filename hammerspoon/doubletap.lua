-- Double-tap a left modifier to send a key (dot-p45): Control -> Return,
-- Command -> Space, Option -> Backspace. They stand in for the ErgoDox
-- right-thumb keys while the right hand is on the mouse. This used to live
-- in Karabiner; Hammerspoon does it with an eventtap, so it also works on
-- a Mac where Karabiner's driver can't be installed.
--
-- The first press is an ordinary modifier. Released with nothing else
-- pressed, it arms its rule for WINDOW seconds; pressing the same modifier
-- again inside that window sends the key instead (held, it repeats). Any
-- other key, modifier or mouse button in between disarms it, so chords
-- like cmd-c, cmd-c or cmd-click, cmd-click stay chords. Other modifiers
-- held at the time carry through: hold Shift and double-tap Control for
-- Shift+Return.
local M = {}

M.WINDOW = 0.3

-- Device-dependent bits of the raw event flags (NX_DEVICEL*KEYMASK), one
-- per physical left modifier. Matching on these rather than key codes
-- also catches Caps Lock remapped to Control in System Settings.
M.RULES = {
  { mask = 0x00000001, flag = "ctrl", key = "return" },
  { mask = 0x00000008, flag = "cmd", key = "space" },
  { mask = 0x00000020, flag = "alt", key = "delete" },
}

-- Every device-dependent modifier bit: left/right Control, Shift, Option,
-- Command. A change in any of them that isn't a rule's disarms.
local DEVICE_BITS = 0x000021ef

-- The pure state machine, kept free of `hs` so make test can drive it.
-- `flags(raw, mods, now)` takes a flagsChanged event's raw flags and its
-- modifier table; `other()` is any key or mouse button going down. Each
-- returns nil (pass the event through) or an action: { down = true|false,
-- key = <key name>, mods = <modifier table to send with it> }, and the
-- triggering event is to be swallowed.
function M.machine(rules, window)
  rules = rules or M.RULES
  window = window or M.WINDOW
  local m = { prev = 0, armed = nil, armedAt = 0, held = {}, active = nil }

  local function spoilHeld()
    for mask in pairs(m.held) do
      m.held[mask] = "used"
    end
  end

  function m.other()
    m.armed = nil
    spoilHeld()
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
        m.other()
      end
      return nil
    end

    local down = raw & rule.mask ~= 0
    if down then
      local armed = m.armed == rule.mask and now - m.armedAt <= window
      m.armed = nil
      spoilHeld()
      if armed and not m.active then
        m.active = rule
        local send = {}
        for k, v in pairs(mods or {}) do
          if k ~= rule.flag then
            send[k] = v
          end
        end
        m.activeMods = send
        return { down = true, key = rule.key, mods = send }
      end
      m.held[rule.mask] = "clean"
      return nil
    end

    if m.active == rule then
      m.active = nil
      return { down = false, key = rule.key, mods = m.activeMods }
    end
    if m.held[rule.mask] == "clean" then
      m.armed, m.armedAt = rule.mask, now
    end
    m.held[rule.mask] = nil
    return nil
  end

  return m
end

-- Marks the events this module posts, so the tap lets them through
-- instead of reading them as "another key" and cutting its own repeat.
local OWN = 0x70343500

local function post(key, mods, down, autorepeat)
  local e = hs.eventtap.event.newKeyEvent(mods, key, down)
  local p = hs.eventtap.event.properties
  e:setProperty(p.eventSourceUserData, OWN)
  if autorepeat then
    e:setProperty(p.keyboardEventAutorepeat, 1)
  end
  e:post()
end

function M.start()
  local types = hs.eventtap.event.types
  local p = hs.eventtap.event.properties
  M.state = M.machine()

  local function stopRepeat()
    if M.repeater then
      M.repeater:stop()
      M.repeater = nil
    end
  end

  local function act(a)
    stopRepeat()
    post(a.key, a.mods, a.down, false)
    if a.down then
      M.repeater = hs.timer.doAfter(hs.eventtap.keyRepeatDelay(), function()
        M.repeater = hs.timer.doEvery(
          hs.eventtap.keyRepeatInterval(),
          function()
            post(a.key, a.mods, true, true)
          end
        )
      end)
    end
  end

  M.tap = hs.eventtap.new({
    types.flagsChanged,
    types.keyDown,
    types.leftMouseDown,
    types.rightMouseDown,
    types.otherMouseDown,
  }, function(e)
    if e:getProperty(p.eventSourceUserData) == OWN then
      return false
    end
    if e:getType() ~= types.flagsChanged then
      stopRepeat()
      M.state.other()
      return false
    end
    local a =
      M.state.flags(e:rawFlags(), e:getFlags(), hs.timer.secondsSinceEpoch())
    if a then
      act(a)
      return true
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
