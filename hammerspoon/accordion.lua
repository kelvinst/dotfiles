-- Clickable window strips for aerospace's accordion layout.
--
-- Aerospace stacks every unfocused window in an accordion at the *same*
-- frame, then shifts the focused one over by `accordion-padding` (100 in
-- `~/.aerospace.toml`). What you see in that gutter is therefore one strip
-- of one window, whether two windows hide behind it or seven — the layout
-- gives no clue how deep the stack is, and no way to reach into it except
-- cycling focus.
--
-- This draws the missing part: the gutter is split into one sliver per
-- hidden window, and clicking a sliver focuses that window directly.
--
-- Why a canvas and not the real windows: aerospace re-asserts window
-- frames about a second after anything else moves them, so a cascade built
-- out of actual windows collapses on a timer. Squeezing them thin through
-- aerospace's own `resize` fares no better — Chrome refuses to go under
-- 500px and aerospace answers by overflowing the container, shoving
-- windows off-screen rather than respecting the floor. Drawn slivers pick
-- no fight with the layout at all.
--
-- The slivers show an app icon and a title, not a thumbnail:
-- `hs.window:snapshot()` returns nil on macOS 26 (the per-window CGWindow
-- capture it relies on is gone; full-screen capture still works).

local M = {}

-- Same launchd-PATH problem as everything else here: Hammerspoon is a GUI
-- app, so `hs.task` inherits a PATH with no `aerospace` on it. Mirrors
-- `[exec.env-vars] PATH` in `~/.aerospace.toml`.
local PATH_PREFIX =
  'PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH" '

-- `hs.task` hands the child an open stdin pipe nothing ever writes to, and
-- the aerospace CLI reads stdin to batch further commands — it blocks
-- forever on it. Same guard `orbit` and the link routing in init.lua open
-- with.
local STDIN_GUARD = "exec </dev/null\n"

-- Matches the JankyBorders colors set in `after-startup-command`, so the
-- strips read as part of the same window chrome rather than a separate
-- widget.
local ACTIVE_COLOR = { red = 0.882, green = 0.890, blue = 0.894, alpha = 1.0 }
local INACTIVE_COLOR = { red = 0.286, green = 0.302, blue = 0.396, alpha = 1.0 }
local SLIVER_ALPHA = 0.98

-- Under this the sliver is all padding and no glyph, so the title is
-- dropped and only the icon is drawn.
local MIN_TITLE_WIDTH = 24

-- Under this even an icon is a smudge; the sliver becomes a plain block.
local MIN_ICON_WIDTH = 14

-- A gutter this thin isn't the accordion padding, it's rounding noise
-- between two frames that were meant to be flush.
local MIN_GUTTER = 8

-- Window events arrive in bursts — focusing a window in another app fires
-- unfocused/focused/moved within a few milliseconds of each other, and
-- each would otherwise spawn its own `aerospace list-windows`.
local DEBOUNCE_SECONDS = 0.08

local canvas = nil
local pending = nil
local task = nil

-- Slivers as last drawn: `{ id, x, width }` in tree order, used to turn a
-- click x-coordinate back into a window id.
local slivers = {}

local function focusWindow(id)
  -- Fire-and-forget: a failed focus leaves the strips as they are, and the
  -- next window event redraws them from aerospace's actual state anyway.
  hs.task
    .new("/bin/sh", nil, {
      "-c",
      STDIN_GUARD .. PATH_PREFIX .. 'aerospace focus --window-id "$1"',
      "sh",
      tostring(id),
    })
    :start()
end

-- Which side of the focused window aerospace opened the accordion gutter
-- on, and how wide. Aerospace exposes no container geometry, so this reads
-- it back off the frames: the container is the union of every window on
-- the workspace, and the focused window is flush with one end of it and
-- inset from the other by `accordion-padding`.
--
-- Taking the union over *all* frames rather than just the unfocused ones
-- matters: a window aerospace has stopped focusing keeps the padded
-- position it was last drawn at (an unfocused Chrome sitting at x=112
-- while the focused window is at x=12), so the unfocused frames alone
-- describe neither edge of the container reliably.
--
-- Returns nil when there is no gutter worth drawing in — one window on the
-- workspace, a fullscreen window, or a tiles layout where every frame is
-- flush.
local function gutterRect(focused, frames)
  if #frames == 0 then
    return nil
  end

  local left, right = focused.x, focused.x + focused.w
  for _, f in ipairs(frames) do
    left = math.min(left, f.x)
    right = math.max(right, f.x + f.w)
  end

  local leftGutter = focused.x - left
  local rightGutter = right - (focused.x + focused.w)

  -- Aerospace opens one gutter, not one per side; whichever is real wins.
  -- A tie means neither is the accordion padding.
  if leftGutter >= MIN_GUTTER and leftGutter > rightGutter then
    return { x = left, y = focused.y, w = leftGutter, h = focused.h }
  elseif rightGutter >= MIN_GUTTER then
    return {
      x = focused.x + focused.w,
      y = focused.y,
      w = rightGutter,
      h = focused.h,
    }
  end

  return nil
end

local function clearCanvas()
  if canvas then
    canvas:delete()
    canvas = nil
  end
  slivers = {}
end

-- `windows` is tree order from aerospace, focused entry already removed.
local function draw(rect, windows)
  clearCanvas()

  if #windows == 0 then
    return
  end

  local width = rect.w / #windows
  canvas = hs.canvas.new(rect)

  for i, win in ipairs(windows) do
    local x = (i - 1) * width

    slivers[#slivers + 1] = { id = win.id, x = x, width = width }

    canvas[#canvas + 1] = {
      type = "rectangle",
      action = "fill",
      fillColor = {
        red = INACTIVE_COLOR.red,
        green = INACTIVE_COLOR.green,
        blue = INACTIVE_COLOR.blue,
        alpha = SLIVER_ALPHA,
      },
      frame = { x = x, y = 0, w = width, h = rect.h },
    }

    -- A hairline on the leading edge of every sliver but the first: it is
    -- what makes four windows read as four rather than one wide block.
    if i > 1 then
      canvas[#canvas + 1] = {
        type = "rectangle",
        action = "fill",
        fillColor = ACTIVE_COLOR,
        frame = { x = x, y = 0, w = 1, h = rect.h },
      }
    end

    local centerX = x + width / 2
    local iconSize = math.min(width * 0.6, 28)
    local iconCenterY = rect.h / 2 - iconSize

    if width >= MIN_ICON_WIDTH and win.bundleId then
      local icon = hs.image.imageFromAppBundle(win.bundleId)
      if icon then
        canvas[#canvas + 1] = {
          type = "image",
          image = icon,
          imageScaling = "scaleProportionally",
          frame = {
            x = centerX - iconSize / 2,
            y = iconCenterY - iconSize / 2,
            w = iconSize,
            h = iconSize,
          },
        }
      end
    end

    if width >= MIN_TITLE_WIDTH and win.title and win.title ~= "" then
      -- Rotated a quarter turn: a sliver is far taller than it is wide, so
      -- the title only fits reading bottom-to-top. The frame is written as
      -- the *horizontal* box the text would occupy, then spun about its own
      -- centre — hence the translate/rotate/translate sandwich.
      --
      -- The matrix methods must be chained with `:`. Chaining them with `.`
      -- type-checks and returns a matrix, but silently the wrong one, and
      -- the text lands somewhere off the canvas entirely.
      local boxLength = math.min(rect.h * 0.4, 460)
      local textCenterY = iconCenterY + iconSize / 2 + 16 + boxLength / 2
      canvas[#canvas + 1] = {
        type = "text",
        text = win.title,
        textSize = math.min(width * 0.42, 13),
        textColor = ACTIVE_COLOR,
        textAlignment = "left",
        textLineBreak = "truncateTail",
        frame = {
          x = centerX - boxLength / 2,
          y = textCenterY - width / 2,
          w = boxLength,
          h = width,
        },
        transformation = hs.canvas.matrix
          .translate(centerX, textCenterY)
          :rotate(-90)
          :translate(-centerX, -textCenterY),
      }
    end
  end

  canvas:level(hs.canvas.windowLevels.floating)
  canvas:clickActivating(false)
  canvas:canvasMouseEvents(true, false, false, false)
  canvas:mouseCallback(function(_, event, _, x, _)
    if event ~= "mouseDown" then
      return
    end
    for _, sliver in ipairs(slivers) do
      if x >= sliver.x and x < sliver.x + sliver.width then
        focusWindow(sliver.id)
        return
      end
    end
  end)
  canvas:show()
end

-- Exposed so the geometry can be asserted from `hs -c` without having to
-- read pixels back off the screen. Sliver `x` is canvas-local; `frame` is
-- what turns it into a screen coordinate.
function M.state()
  return {
    slivers = slivers,
    count = #slivers,
    frame = canvas and canvas:frame() or nil,
  }
end

local function render()
  pending = nil

  -- Never two at once: the previous listing is about to be superseded by
  -- this one, and reassigning `task` below would drop the reference
  -- keeping it alive mid-read.
  if task and task:isRunning() then
    task:terminate()
  end

  local function done(code, stdout, _)
    if code ~= 0 then
      clearCanvas()
      return
    end

    local focusedId = nil
    local focusedLayout = nil
    local ordered = {}

    for line in (stdout or ""):gmatch("[^\n]+") do
      local id, bundleId, layout, isFocused, title =
        line:match("^(%d+)|([^|]*)|([^|]*)|([^|]*)|(.*)$")
      if id then
        ordered[#ordered + 1] = {
          id = tonumber(id),
          bundleId = bundleId ~= "" and bundleId or nil,
          title = title,
        }
        -- aerospace prints the workspace listing and the focused window in
        -- one batch; the focused line is tagged rather than looked up
        -- separately so both come from a single consistent read.
        if isFocused == "focused" then
          focusedId = tonumber(id)
          focusedLayout = layout
        end
      end
    end

    -- Only a horizontal accordion has the gutter this draws into. In tiles
    -- the focused window doesn't span the container at all, so the "gutter"
    -- the geometry below would find is just the space the sibling windows
    -- occupy — a wide overlay painted straight over real windows. A
    -- vertical accordion has a real gutter too, but a horizontal one
    -- (above or below the focused window), which these slivers aren't laid
    -- out for.
    if focusedLayout ~= "h_accordion" then
      clearCanvas()
      return
    end

    local focusedWindow = focusedId and hs.window.get(focusedId)
    if not focusedWindow then
      clearCanvas()
      return
    end

    local focusedFrame = focusedWindow:frame()
    local others, siblingFrames = {}, {}

    for _, win in ipairs(ordered) do
      if win.id ~= focusedId then
        local w = hs.window.get(win.id)
        if w then
          others[#others + 1] = win
          siblingFrames[#siblingFrames + 1] = w:frame()
        end
      end
    end

    local rect = gutterRect(focusedFrame, siblingFrames)
    if not rect then
      clearCanvas()
      return
    end

    draw(rect, others)
  end

  -- One read for both the tree order and which entry is focused. Asking
  -- twice would let a focus change land between the two calls and draw a
  -- strip that includes the window you are looking at.
  local script = STDIN_GUARD
    .. PATH_PREFIX
    .. [[
focused=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)
aerospace list-windows --workspace focused \
  --format '%{window-id}|%{app-bundle-id}|%{window-parent-container-layout}|%{window-title}' \
  2>/dev/null |
  while IFS='|' read -r id bundle layout title; do
    if [ "$id" = "$focused" ]; then
      printf '%s|%s|%s|focused|%s\n' "$id" "$bundle" "$layout" "$title"
    else
      printf '%s|%s|%s||%s\n' "$id" "$bundle" "$layout" "$title"
    fi
  done
]]

  task = hs.task.new("/bin/sh", done, { "-c", script })
  task:start()
end

function M.refresh()
  if pending then
    pending:stop()
  end
  pending = hs.timer.doAfter(DEBOUNCE_SECONDS, render)
end

-- Held at module scope for the same reason `screenWatcher` is global in
-- init.lua: nothing else references the filter, and a collected one stops
-- delivering events silently.
local filter = nil

function M.start()
  filter = hs.window.filter.new(nil)
  filter:subscribe({
    hs.window.filter.windowFocused,
    hs.window.filter.windowCreated,
    hs.window.filter.windowDestroyed,
    hs.window.filter.windowMoved,
    hs.window.filter.windowUnfocused,
  }, function()
    M.refresh()
  end)

  M.refresh()
end

return M
