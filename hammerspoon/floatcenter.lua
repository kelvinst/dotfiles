-- Centers every new floating window on the screen you were working on.
-- Without it a dialog opens wherever its app last put one, often on the
-- other monitor, out of sight. "Floating" means any real window (standard,
-- dialog or floating panel, never a menu or popover) AeroSpace doesn't tile:
-- the ones it floats and the dialogs it leaves alone.
local M = {}

-- Same bare-launchd-PATH problem as windowhints.lua: `aerospace` isn't on
-- it.
local PATH_PREFIX =
  'PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH" '

-- AeroSpace decides a new window's layout a moment after it appears.
local SETTLE = 0.3

-- The focused window and the one before it. A new window often takes focus
-- before its created event arrives, so the screen you were on is the
-- previous window's then.
local focused, previous = nil, nil

local function onFocused(win)
  if win ~= focused then
    previous, focused = focused, win
  end
end

local function workScreen(win)
  local origin = focused
  if origin == nil or origin:id() == win:id() then
    origin = previous
  end
  return origin and origin:screen() or hs.mouse.getCurrentScreen()
end

local SUBROLES = {
  AXStandardWindow = true,
  AXDialog = true,
  AXSystemDialog = true,
  AXFloatingWindow = true,
}

local function onCreated(win)
  local id = win:id()
  if not id or not SUBROLES[win:subrole()] then
    return
  end
  local screen = workScreen(win)
  hs.timer.doAfter(SETTLE, function()
    hs.task
      .new("/bin/sh", function(_, out)
        -- Tiled shows as h_tiles, v_accordion and so on; floating, or no
        -- line at all for a window AeroSpace leaves alone.
        if not out:match("_tiles") and not out:match("_accordion") then
          win:centerOnScreen(screen, true, 0)
        end
      end, {
        "-c",
        PATH_PREFIX
          .. "aerospace list-windows --all"
          .. " --format '%{window-id} %{window-layout}'"
          .. " | grep '^"
          .. id
          .. " '",
      })
      :start()
  end)
end

M.filter = hs.window.filter.new():setDefaultFilter({ allowRoles = "*" })
M.filter:subscribe(hs.window.filter.windowFocused, onFocused)
M.filter:subscribe(hs.window.filter.windowCreated, onCreated)

return M
