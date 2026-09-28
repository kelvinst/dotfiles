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

-- The window that was focused when the overlay opened. Esc, alt-f3 again
-- or a key matching no label all hand focus back to it.
local origin = nil

-- Accordion windows flipped to tiles for the overlay, as window id ->
-- the accordion layout to put back when it closes.
local flipped = {}

-- For each workspace with a flipped stack, the window its accordion showed
-- before the flip, and which workspace every visible window is on. The
-- restack walk leaves another window on top of each stack, and a flipped
-- stack comes back showing that one unless it gets focus again.
local shownBefore = {}
local workspaceOf = {}

-- Set once the restack has walked focus through the overlapping tiles,
-- so hiding the overlay knows focus has moved off `origin`.
local walked = false

-- The flip to tiles lands a beat after the command returns; frames read
-- before that are still the accordion's.
local SETTLE_SECONDS = 0.2
local pending = nil

-- Runs one shell line of aerospace commands, held in `M` under `key` so
-- the task isn't collected mid-run. `;` rather than `&&`: one command
-- failing — a window closed while the overlay was up — mustn't skip the
-- rest of the restore.
local function aerospace(key, cmds)
  M[key] = hs.task.new("/bin/sh", nil, {
    "-c",
    PATH_PREFIX .. table.concat(cmds, "; "),
  })
  M[key]:start()
end

-- Every window id, front to back. hs.window._orderedwinids() is private
-- but fast; an update that drops it would error after the key tap has
-- started, swallowing every key until Esc. orderedWindows() is public and
-- slower (~25ms), so it's the fallback that keeps the overlay working.
local function orderedIds()
  if hs.window._orderedwinids then
    return hs.window._orderedwinids()
  end
  local ids = {}
  for i, win in ipairs(hs.window.orderedWindows()) do
    ids[i] = win:id()
  end
  return ids
end

-- Undo what the overlay did to the windows, then focus the picked window,
-- or `origin` with none picked. All through aerospace rather than
-- hs.window:focus(): aerospace keeps its own idea of the focused node, and
-- going around it leaves the tree out of step with what is on screen.
local function finish(targetId)
  if M.walkTask and M.walkTask:isRunning() then
    -- Terminating the sh leaves its running `aerospace focus` alive, and
    -- that can land after the focus below. Kill it first, synchronously.
    hs.execute("pkill -TERM -P " .. M.walkTask:pid())
    M.walkTask:terminate()
  end

  local cmds = {}
  local anyFlipped = false
  for id, layout in pairs(flipped) do
    table.insert(cmds, "aerospace layout --window-id " .. id .. " " .. layout)
    anyFlipped = true
  end
  -- A stack flipped back, or walked over, shows whichever window was left
  -- on top, so focus is set again even when it stays on `origin` — first
  -- on what each other stack showed before, then on the final window.
  local final = targetId or origin
  for ws, id in pairs(shownBefore) do
    if ws ~= workspaceOf[final] then
      table.insert(cmds, "aerospace focus --window-id " .. id)
    end
  end
  if final and (final ~= origin or walked or anyFlipped) then
    table.insert(cmds, "aerospace focus --window-id " .. final)
  end

  walked = false
  flipped = {}
  shownBefore = {}
  workspaceOf = {}
  origin = nil
  if #cmds > 0 then
    aerospace("finishTask", cmds)
  end
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
      .. " --format '%{window-id}|%{app-pid}|%{workspace}|%{window-layout}"
      .. "|%{app-name}'"
  )
  if not ok then
    return {}
  end

  -- Looking each id up through its app is much cheaper than hs.window.get,
  -- which walks every window of every running app.
  local byPid = {}
  local windows = {}
  for line in out:gmatch("[^\n]+") do
    local id, pid, ws, layout, app =
      line:match("^(%d+)|(%d+)|([^|]*)|([^|]*)|(.*)$")
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
        table.insert(windows, {
          id = id,
          app = app,
          workspace = ws,
          layout = layout,
          win = w,
          frame = w:frame(),
        })
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
local LABEL_PAD = 16

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
      home = {
        cx = cx,
        cy = cy,
        frame = w.frame,
        width = w.frame.w,
        members = {},
      }
      table.insert(clusters, home)
    end
    home.width = math.max(home.width, w.frame.w)
    table.insert(home.members, i)
  end
  return clusters
end

-- One rect per window, in the same order. A lone window gets its label
-- centred on it — unless `covered[i]` says its centre sits under another
-- window, as happens when tiles too narrow for their apps' minimum widths
-- overlap. Then the label goes at its left edge, vertically centred, the
-- strip of it that stays visible. A stack gets its labels side by side in
-- a row centred on the stack, wrapping onto more rows when the row would
-- outgrow the widest window in it — a floating window centred over the
-- stack joins it too.
local function layoutLabels(windows, covered)
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
    local fixedX = nil
    if n == 1 and covered[c.members[1]] then
      fixedX = c.frame.x + LABEL_PAD
    end
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
        x = fixedX or left + col * (LABEL_W + LABEL_GAP),
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

-- Bring `list` to the front in order, so the last ends up on top, by
-- walking aerospace focus through it. hs.window:raise() doesn't hold up:
-- fired back to back the raises land out of order, and even spaced out
-- the last one — WhatsApp — kept ending up under the rest. The walk
-- leaves focus on the last window; finish() takes it back to `origin`
-- only when the overlay closes, since doing it here would pull that
-- window back over the stack whenever it sits in one.
local function restack(list)
  if #list == 0 then
    return
  end
  local cmds = {}
  for _, w in ipairs(list) do
    table.insert(cmds, "aerospace focus --window-id " .. w.id)
  end
  walked = true
  aerospace("walkTask", cmds)
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

  -- Tiles too narrow for their apps' minimum widths overlap — whether the
  -- overlay just flipped them from accordion or they were tiles already.
  -- On every workspace where tiles overlap, raise them left to right, so
  -- the rightmost ends up on top and each one's left edge — where its
  -- label goes — shows past the one before it. Floating windows go last
  -- so they stay above the tiles.
  local byWorkspace = {}
  for _, w in ipairs(windows) do
    byWorkspace[w.workspace] = byWorkspace[w.workspace] or {}
    table.insert(byWorkspace[w.workspace], w)
  end

  local raised = {}
  for _, group in pairs(byWorkspace) do
    local overlap = false
    for i, a in ipairs(group) do
      for j = i + 1, #group do
        local b = group[j]
        if
          a.layout ~= "floating"
          and b.layout ~= "floating"
          and a.frame:intersect(b.frame).area > 0
        then
          overlap = true
        end
      end
    end

    if overlap then
      for _, floating in ipairs({ false, true }) do
        for _, w in ipairs(group) do
          if (w.layout == "floating") == floating then
            table.insert(raised, w)
          end
        end
      end
    end
  end
  restack(raised)

  -- Front-to-back rank of every window, lower is nearer the front. The
  -- restack above runs in the background, so the raised windows are
  -- ranked by the order it will leave them in, all in front of everything
  -- else.
  local rank = {}
  for i, id in ipairs(orderedIds()) do
    rank[id] = i
  end
  for k, w in ipairs(raised) do
    rank[w.win:id()] = -k
  end

  -- Whether a frame fits inside a single screen, give or take a pixel.
  local screens = {}
  for _, sc in ipairs(hs.screen.allScreens()) do
    table.insert(screens, sc:fullFrame())
  end
  local function onOneScreen(f)
    for _, sf in ipairs(screens) do
      if
        f.x >= sf.x - 1
        and f.y >= sf.y - 1
        and f.x + f.w <= sf.x + sf.w + 1
        and f.y + f.h <= sf.y + sf.h + 1
      then
        return true
      end
    end
    return false
  end

  -- Whether each window's centre is hidden under a window in front of it,
  -- or the window straddles two screens — the rightmost tile on the side
  -- monitor spills onto the big one, and a label centred on it would sit
  -- on the seam.
  local covered = {}
  for i, w in ipairs(windows) do
    covered[i] = not onOneScreen(w.frame)
    local cx = w.frame.x + w.frame.w / 2
    local cy = w.frame.y + w.frame.h / 2
    local mine = rank[w.win:id()] or math.huge
    for _, o in ipairs(windows) do
      local f = o.frame
      if covered[i] then
        break
      end
      if
        o ~= w
        and (rank[o.win:id()] or math.huge) < mine
        and cx >= f.x
        and cx < f.x + f.w
        and cy >= f.y
        and cy < f.y + f.h
      then
        covered[i] = true
        break
      end
    end
  end

  local labels = makeLabels(#windows)
  local rects = layoutLabels(windows, covered)
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
  -- in what order the rest sit. Flipping every accordion on the visible
  -- workspaces — both monitors, so a window on the other one is as easy
  -- to reach — to tiles for the length of the overlay lays each window
  -- out side by side, so each label lands on its real window. Flipped per
  -- window with `--window-id`, which leaves focus alone and covers nested
  -- stacks too; each keeps its orientation, h_accordion to h_tiles.
  origin = hs.execute(
    PATH_PREFIX .. "aerospace list-windows --focused --format '%{window-id}'"
  ):match("%d+")

  local out = hs.execute(
    PATH_PREFIX
      .. "aerospace list-windows --workspace visible"
      .. " --format '%{window-id}|%{workspace}|%{window-layout}'"
  )
  local cmds = {}
  local stacked = {}
  for id, ws, layout in (out or ""):gmatch("(%d+)|([^|\n]*)|(%S+)") do
    workspaceOf[id] = ws
    local orientation = layout:match("^([hv])_accordion$")
    if orientation then
      flipped[id] = layout
      stacked[ws] = true
      table.insert(
        cmds,
        "aerospace layout --window-id " .. id .. " " .. orientation .. "_tiles"
      )
    end
  end

  -- What each stack shows now is its frontmost window.
  for _, winId in ipairs(orderedIds()) do
    local id = tostring(winId)
    local ws = workspaceOf[id]
    if ws and stacked[ws] and not shownBefore[ws] and flipped[id] then
      shownBefore[ws] = id
    end
  end

  if #cmds > 0 then
    hs.execute(PATH_PREFIX .. table.concat(cmds, " && "))
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
