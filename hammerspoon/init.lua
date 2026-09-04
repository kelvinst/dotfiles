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

-- What the chain falls back to once those are spent, rather than stopping
-- dead. A wedged aerospace outlasts a handful of seconds easily, and the
-- burst of screen changes a dock produces is spent by then.
local SLOW_RETRY_SECONDS = 60

-- How many settle intervals a sync may overrun before it is killed rather
-- than waited on. `orbit sync-monitors` can block on a wedged aerospace,
-- and deferring to it forever is the one failure this whole chain can't
-- see or report.
local MAX_DEFERRALS = 10

local pending = nil
local attempts = 0
local deferrals = 0

-- Held for the same reason as the watcher below: a task that gets
-- collected mid-run never calls back, and the retry goes with it.
local task = nil

local function syncMonitors()
  pending = nil

  -- Never two at once. `orbit sync-monitors` takes the workspace-mutation
  -- lock, so a second one launched over a running first would lose it and
  -- fail for no reason but the collision — and reassigning `task` below
  -- would drop the reference holding the first one alive. Wait it out; the
  -- attempt counter is untouched, because nothing was attempted.
  if task and task:isRunning() then
    deferrals = deferrals + 1

    if deferrals <= MAX_DEFERRALS then
      pending = hs.timer.doAfter(SETTLE_SECONDS, syncMonitors)
      return
    end

    -- Past that it isn't slow, it's stuck, and waiting on it silently is
    -- worse than killing it: the run that replaces it either works or
    -- fails somewhere this can say so.
    hs.printf(
      "orbit sync-monitors overran %ds, killing it",
      SETTLE_SECONDS * MAX_DEFERRALS
    )
    task:terminate()
    task = nil
    deferrals = 0
    pending = hs.timer.doAfter(SETTLE_SECONDS, syncMonitors)
    return
  end

  deferrals = 0
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

    -- A screen change during the run may already have armed a timer, and
    -- it is stale the moment this one goes on.
    if pending then
      pending:stop()
    end

    if attempts < MAX_ATTEMPTS then
      -- Backing off: three tries crammed into one settle interval all
      -- land while whatever went wrong is still going wrong. Clamped
      -- because a screen change during the run resets the counter, and a
      -- negative exponent would come back under the settle interval.
      local delay = SETTLE_SECONDS * 2 ^ math.max(attempts - 1, 0)
      pending = hs.timer.doAfter(delay, syncMonitors)
    else
      -- Dropping the chain here would leave the screens as they are until
      -- the user replugs, which is what the retry exists to avoid. A slow
      -- one keeps going instead; a success or a fresh screen change ends
      -- it.
      attempts = 0
      pending = hs.timer.doAfter(SLOW_RETRY_SECONDS, syncMonitors)
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
