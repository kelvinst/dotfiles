-- Aerospace has no monitor-connect callback of its own (0.20.3 only offers
-- `after-startup-command` and the focus/mode callbacks), so the display
-- watcher lives here. Every screen change re-runs `orbit sync-monitors`,
-- which pins workspaces 0/G/M/P to the secondary monitor and swaps the
-- main-monitor layouts between `tiles` and `accordion`.

-- Hammerspoon is a GUI app, so `hs.task` inherits the bare launchd PATH —
-- neither `orbit` nor the `aerospace` CLI it shells out to is on it. The
-- prefix mirrors `[exec.env-vars] PATH` in `~/.aerospace.toml`.
local SYNC_MONITORS =
  'PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH" '
  .. "orbit sync-monitors"

-- A single connect fires the watcher several times, and aerospace needs a
-- moment to migrate its workspaces onto the new monitor before the layouts
-- are worth touching.
local SETTLE_SECONDS = 2

local pending = nil

local function syncMonitors()
  pending = nil
  hs.task.new("/bin/sh", nil, { "-c", SYNC_MONITORS }):start()
end

local screenWatcher = hs.screen.watcher.new(function()
  if pending then
    pending:stop()
  end
  pending = hs.timer.doAfter(SETTLE_SECONDS, syncMonitors)
end)

screenWatcher:start()
