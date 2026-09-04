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

-- `orbit sync-monitors` exits non-zero and records nothing when aerospace
-- isn't in a state worth reading — a monitor count that won't parse, a
-- seeding that didn't land — on the understanding that the run comes back.
-- It has to come back from here: a dock is one burst of screen changes
-- collapsed into a single debounced run, so there is no later event to
-- wait for.
local MAX_ATTEMPTS = 3

local pending = nil
local attempts = 0

-- Held for the same reason as the watcher below: a task that gets
-- collected mid-run never calls back, and the retry goes with it.
local task = nil

local function syncMonitors()
  pending = nil
  attempts = attempts + 1

  local function done(code, _, stderr)
    if code == 0 then
      attempts = 0
      return
    end

    hs.printf(
      "orbit sync-monitors exited %d (attempt %d/%d) %s",
      code,
      attempts,
      MAX_ATTEMPTS,
      stderr or ""
    )

    if attempts < MAX_ATTEMPTS then
      pending = hs.timer.doAfter(SETTLE_SECONDS, syncMonitors)
    else
      attempts = 0
    end
  end

  task = hs.task.new("/bin/sh", done, { "-c", SYNC_MONITORS })
  task:start()
end

-- Global on purpose: a local would go out of scope when this chunk
-- returns, and nothing else holds the watcher — the callback closure
-- captures `pending` and `syncMonitors`, not the watcher itself. The next
-- collection would finalize it and screen changes would stop arriving,
-- silently and with nothing logged.
screenWatcher = hs.screen.watcher.new(function()
  if pending then
    pending:stop()
  end
  -- A fresh screen change is a fresh situation, whatever the last one's
  -- retries were up to.
  attempts = 0
  pending = hs.timer.doAfter(SETTLE_SECONDS, syncMonitors)
end)

screenWatcher:start()
