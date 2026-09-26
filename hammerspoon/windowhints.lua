-- Vimium-style window hints. alt-f3 drops a letter label on every window of
-- the visible aerospace workspaces — both monitors at once — and typing a
-- label focuses that window. Escape, or any key that matches no label,
-- dismisses the overlay.
local M = {}

-- Home row first, so the common case of a handful of windows never leaves
-- it.
local ALPHABET = "asdfghjklqwertyuiopzxcvbnm"

local HOTKEY_MODS = { alt = true }
local HOTKEY_KEY = "f3"

local LABEL_W = 220
local LABEL_H = 64

-- Same bare-launchd-PATH problem as monitors.lua: `aerospace` isn't on it.
local PATH_PREFIX =
  'PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH" '

-- Live state while the overlay is up. Held on the module table for the same
-- reason init.lua uses globals: a collected eventtap stops firing silently,
-- and the keyboard would be left swallowed with nothing listening.
local canvases = {}
local tap = nil
local hints = {}
local typed = ""

-- `aerospace focus` rather than hs.window:focus(): aerospace keeps its own
-- idea of the focused node, and going around it leaves the tree out of step
-- with what is on screen. Held in `M` so the task isn't collected mid-run.
local function focusWindow(id)
  M.focusTask = hs.task.new("/bin/sh", nil, {
    "-c",
    PATH_PREFIX .. "aerospace focus --window-id " .. id,
  })
  M.focusTask:start()
end

-- Every window on a visible workspace, with its on-screen frame. Aerospace
-- parks windows of hidden workspaces off in a screen corner, so asking it
-- for `--workspace visible` is what keeps those out; hs.window supplies
-- the frame, which aerospace doesn't expose. An aerospace window id is the
-- CGWindowID, which is also what hs.window:id() returns.
local function visibleWindows()
  local out, ok = hs.execute(
    PATH_PREFIX
      .. "aerospace list-windows --workspace visible"
      .. " --format '%{window-id}|%{app-pid}|%{app-name}'"
  )
  if not ok then
    return {}
  end

  -- Looking each id up through its app is much cheaper than hs.window.get,
  -- which walks every window of every running app.
  local byPid = {}
  local windows = {}
  for line in out:gmatch("[^\n]+") do
    local id, pid, app = line:match("^(%d+)|(%d+)|(.*)$")
    if id then
      pid = tonumber(pid)
      if byPid[pid] == nil then
        byPid[pid] = {}
        local application = hs.application.applicationForPID(pid)
        for _, w in ipairs(application and application:allWindows() or {}) do
          byPid[pid][w:id()] = w
        end
      end

      local w = byPid[pid][tonumber(id)]
      if w and not w:isMinimized() then
        table.insert(windows, { id = id, app = app, frame = w:frame() })
      end
    end
  end
  return windows
end

-- `n` labels of equal length, so no label is a prefix of another and a
-- label is done the moment its last letter is typed.
local function makeLabels(n)
  local letters = {}
  for c in ALPHABET:gmatch(".") do
    table.insert(letters, c)
  end

  local labels = { "" }
  repeat
    local longer = {}
    for _, prefix in ipairs(labels) do
      for _, c in ipairs(letters) do
        table.insert(longer, prefix .. c)
      end
    end
    labels = longer
  until #labels >= n
  return labels
end

-- Centre of the window, nudged down past any label already placed there.
-- Accordion stacks put their windows a few pixels apart, which would
-- otherwise pile every label onto the same spot.
local function placeLabel(frame, placed)
  local x = frame.x + (frame.w - LABEL_W) / 2
  local y = frame.y + (frame.h - LABEL_H) / 2
  local moved = true
  while moved do
    moved = false
    for _, p in ipairs(placed) do
      if math.abs(p.x - x) < LABEL_W and math.abs(p.y - y) < LABEL_H then
        y = p.y + LABEL_H + 6
        moved = true
      end
    end
  end
  local rect = { x = x, y = y, w = LABEL_W, h = LABEL_H }
  table.insert(placed, rect)
  return rect
end

local function drawLabel(hint)
  local c = hs.canvas.new(hint.rect)
  c:level(hs.canvas.windowLevels.overlay)
  c:appendElements({
    type = "rectangle",
    action = "fill",
    roundedRectRadii = { xRadius = 10, yRadius = 10 },
    fillColor = { red = 0.1, green = 0.1, blue = 0.12, alpha = 0.92 },
  }, {
    type = "text",
    text = hs.styledtext.new(hint.label:upper(), {
      font = { name = "Menlo-Bold", size = 30 },
      color = { red = 1, green = 0.8, blue = 0.2 },
      paragraphStyle = { alignment = "center" },
    }),
    frame = { x = 0, y = 4, w = LABEL_W, h = 38 },
  }, {
    type = "text",
    text = hs.styledtext.new(hint.app, {
      font = { size = 13 },
      color = { white = 0.85 },
      paragraphStyle = {
        alignment = "center",
        lineBreak = "truncateTail",
      },
    }),
    frame = { x = 8, y = 42, w = LABEL_W - 16, h = 18 },
  })
  c:show()
  return c
end

-- Dim the labels that no longer match what has been typed so far.
local function refresh()
  for i, hint in ipairs(hints) do
    local match = hint.label:sub(1, #typed) == typed
    canvases[i]:alpha(match and 1 or 0.25)
  end
end

function M.hide()
  if tap then
    tap:stop()
    tap = nil
  end
  for _, c in ipairs(canvases) do
    c:delete()
  end
  canvases = {}
  hints = {}
  typed = ""
end

local function onKey(event)
  -- Holding alt-f3 a beat too long would otherwise feed its repeats in
  -- as keystrokes.
  local props = hs.eventtap.event.properties
  if event:getProperty(props.keyboardEventAutorepeat) ~= 0 then
    return true
  end

  local key = hs.keycodes.map[event:getKeyCode()]
  if key == "escape" then
    M.hide()
    return true
  end
  if key == "delete" then
    typed = typed:sub(1, -2)
    refresh()
    return true
  end

  local char = event:getCharacters(true)
  local candidate = typed .. (char or ""):lower()
  local target = nil
  local anyPrefix = false
  for _, hint in ipairs(hints) do
    if hint.label == candidate then
      target = hint
    elseif hint.label:sub(1, #candidate) == candidate then
      anyPrefix = true
    end
  end

  if target then
    M.hide()
    focusWindow(target.id)
  elseif anyPrefix then
    typed = candidate
    refresh()
  else
    M.hide()
  end
  return true
end

function M.show()
  if tap then
    M.hide()
    return
  end

  local windows = visibleWindows()
  if #windows == 0 then
    return
  end

  -- Top-left to bottom-right across both monitors, so the same layout
  -- tends to get the same letters.
  table.sort(windows, function(a, b)
    if a.frame.x ~= b.frame.x then
      return a.frame.x < b.frame.x
    end
    return a.frame.y < b.frame.y
  end)

  local labels = makeLabels(#windows)
  local placed = {}
  for i, w in ipairs(windows) do
    local hint = {
      id = w.id,
      app = w.app,
      label = labels[i],
      rect = placeLabel(w.frame, placed),
    }
    table.insert(hints, hint)
    table.insert(canvases, drawLabel(hint))
  end

  tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, onKey)
  tap:start()
end

-- Bound here rather than in aerospace.toml: aerospace would only turn
-- around and shell out to `hs -c`, adding a round trip before the labels
-- show. Keep alt-f3 unbound in aerospace so it reaches Hammerspoon.
--
-- An event tap rather than hs.hotkey: hs.hotkey goes through
-- RegisterEventHotKey, which refuses a chord someone else already holds,
-- and something on this Mac still holds alt-f3 even with the Mission
-- Control shortcut turned off. A tap sees the key before any of that, the
-- way skhd does.
local function onTrigger(event)
  if hs.keycodes.map[event:getKeyCode()] ~= HOTKEY_KEY then
    return false
  end
  -- F-keys carry the fn flag on a Mac keyboard; only the modifiers named
  -- in HOTKEY_MODS count.
  local flags = event:getFlags()
  for _, mod in ipairs({ "cmd", "alt", "shift", "ctrl" }) do
    if (flags[mod] or false) ~= (HOTKEY_MODS[mod] or false) then
      return false
    end
  end
  M.show()
  return true
end

M.trigger = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, onTrigger)
M.trigger:start()

return M
