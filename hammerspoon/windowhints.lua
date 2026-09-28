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

local LABEL_W = 200
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

-- Set while the focused accordion stack is flipped to tiles for the
-- overlay, so hiding it knows to flip it back.
local flipped = false

-- The flip to tiles lands a beat after the command returns; frames read
-- before that are still the accordion's.
local SETTLE_SECONDS = 0.2
local pending = nil

-- Put the stack back to accordion if the overlay flipped it, then focus
-- the picked window. Both go through aerospace rather than
-- hs.window:focus(): aerospace keeps its own idea of the focused node, and
-- going around it leaves the tree out of step with what is on screen.
-- `layout` acts on the focused window, which the overlay never moves, so
-- it has to run before `focus`. Held in `M` so the task isn't collected
-- mid-run.
local function finish(targetId)
  local cmds = {}
  if flipped then
    table.insert(cmds, "aerospace layout accordion")
    flipped = false
  end
  if targetId then
    table.insert(cmds, "aerospace focus --window-id " .. targetId)
  end
  if #cmds == 0 then
    return
  end
  M.finishTask = hs.task.new("/bin/sh", nil, {
    "-c",
    PATH_PREFIX .. table.concat(cmds, " && "),
  })
  M.finishTask:start()
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

local LABEL_GAP = 8

-- Windows whose centred labels would land on top of each other: an
-- accordion stack puts its windows a few pixels apart, so every label
-- would pile onto the same spot in the middle of the screen.
local function clusterWindows(windows)
  local clusters = {}
  for i, w in ipairs(windows) do
    local cx = w.frame.x + w.frame.w / 2
    local cy = w.frame.y + w.frame.h / 2
    local home = nil
    for _, c in ipairs(clusters) do
      if math.abs(c.cx - cx) < LABEL_W and math.abs(c.cy - cy) < LABEL_H then
        home = c
        break
      end
    end
    if not home then
      home = { cx = cx, cy = cy, width = w.frame.w, members = {} }
      table.insert(clusters, home)
    end
    home.width = math.max(home.width, w.frame.w)
    table.insert(home.members, i)
  end
  return clusters
end

-- One rect per window, in the same order. A lone window gets its label
-- centred on it; a stack gets its labels side by side in a row centred on
-- the stack, wrapping onto more rows when the row would outgrow the widest
-- window in it — a floating window centred over the stack joins it too.
local function layoutLabels(windows)
  local rects = {}
  local placed = {}

  -- Biggest stacks first, so their rows stay put and it is a lone floating
  -- window's label that moves out of the way, not a whole row.
  local clusters = clusterWindows(windows)
  table.sort(clusters, function(a, b)
    return #a.members > #b.members
  end)

  for _, c in ipairs(clusters) do
    local n = #c.members
    local fit = math.floor((c.width + LABEL_GAP) / (LABEL_W + LABEL_GAP))
    local cols = math.max(1, math.min(n, fit))
    local rows = math.ceil(n / cols)
    local top = c.cy - (rows * LABEL_H + (rows - 1) * LABEL_GAP) / 2

    for k, idx in ipairs(c.members) do
      local row = (k - 1) // cols
      local col = (k - 1) % cols
      local inRow = math.min(cols, n - row * cols)
      local left = c.cx
        - (inRow * LABEL_W + (inRow - 1) * LABEL_GAP) / 2
      local rect = {
        x = left + col * (LABEL_W + LABEL_GAP),
        y = top + row * (LABEL_H + LABEL_GAP),
        w = LABEL_W,
        h = LABEL_H,
      }

      -- A floating window centred near a stack, but not near enough to
      -- join it, can still land on the stack's row: drop it below.
      local moved = true
      while moved do
        moved = false
        for _, p in ipairs(placed) do
          if
            math.abs(p.x - rect.x) < LABEL_W
            and math.abs(p.y - rect.y) < LABEL_H
          then
            rect.y = p.y + LABEL_H + LABEL_GAP
            moved = true
          end
        end
      end

      table.insert(placed, rect)
      rects[idx] = rect
    end
  end
  return rects
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

-- Tear the overlay down, then restore the stack and focus `targetId` when
-- given.
function M.hide(targetId)
  if pending then
    pending:stop()
    pending = nil
  end
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
  finish(targetId)
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
    M.hide(target.id)
  elseif anyPrefix then
    typed = candidate
    refresh()
  else
    M.hide()
  end
  return true
end

local function drawHints()
  pending = nil
  local windows = visibleWindows()
  if #windows == 0 then
    M.hide()
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
  local rects = layoutLabels(windows)
  for i, w in ipairs(windows) do
    local hint = {
      id = w.id,
      app = w.app,
      label = labels[i],
      rect = rects[i],
    }
    table.insert(hints, hint)
    table.insert(canvases, drawLabel(hint))
  end
end

function M.show()
  if tap then
    M.hide()
    return
  end

  -- Keys typed while the stack settles are the overlay's too: Escape backs
  -- out, and anything else dismisses it like an unknown label would.
  tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, onKey)
  tap:start()

  -- An accordion stack hides all but one window, and aerospace can't say
  -- in what order the rest sit. Flipping it to tiles for the length of the
  -- overlay lays every window out side by side, so each label lands on its
  -- real window. Only the focused stack: `layout` acts on the focused
  -- window, and a stack on the other monitor would need focus moved there
  -- and back.
  local layout = hs.execute(
    PATH_PREFIX
      .. "aerospace list-windows --focused --format '%{window-layout}'"
  )
  if layout and layout:find("accordion") then
    hs.execute(PATH_PREFIX .. "aerospace layout tiles")
    flipped = true
    pending = hs.timer.doAfter(SETTLE_SECONDS, drawHints)
  else
    drawHints()
  end
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
