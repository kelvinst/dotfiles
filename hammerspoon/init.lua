-- Loading `hs.ipc` is what makes the `hs` command-line tool able to talk to
-- the running Hammerspoon — without it `hs -c ...` just times out. The CLI
-- itself is a symlink into the app bundle; see README for how it is
-- installed.
require("hs.ipc")

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

-- Link routing. macOS hands a clicked link to Chrome, and Chrome drops the
-- new tab into whichever of its windows it focused last. That window is
-- often on another aerospace workspace — or another monitor — so clicking a
-- link in kitty/Claude yanks the whole desktop somewhere else. Route
-- http(s) through here instead: focus the Chrome window that lives on the
-- *focused* workspace first, so Chrome's "last focused window" is the one
-- in front of us when the URL lands. With no Chrome window on this
-- workspace, nothing is focused and the stock behaviour takes over.
--
-- Only fires while Hammerspoon is the registered http/https handler. One
-- call covers both schemes:
--   hs -c 'hs.urlevent.setDefaultHandler("http")'
--
-- Deliberately not paired with `hs.urlevent.setRestoreHandler`: that hands
-- the schemes back to the browser on every *config reload*, not just on
-- exit, so link routing would switch itself off the first time this file
-- is edited.

local BROWSER_BUNDLE_ID = "com.google.Chrome"

-- $0 is a throwaway shell name, $1 the bundle id, $2 the URL — passed as
-- argv rather than interpolated so URLs never reach the shell as code.
-- Same launchd-PATH problem as above: `aerospace` is not on Hammerspoon's
-- inherited PATH.
local OPEN_LINK = [[
# `hs.task` hands the child an open stdin pipe nothing ever writes to, and
# the aerospace CLI reads stdin by default to batch further commands — it
# would block forever on it. Same guard `orbit` opens with.
exec </dev/null

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Prefer the window we are actually looking at. Picking the first browser
# window on the workspace would yank focus off the one in front of us when
# two of them are tiled side by side — the same annoyance across two
# windows instead of two workspaces.
focused=$(aerospace list-windows --focused \
  --format '%{window-id} %{app-bundle-id}' 2>/dev/null)
case "$focused" in
*" $1") window_id=${focused%% *} ;;
*)
  window_id=$(aerospace list-windows --workspace focused --app-bundle-id "$1" \
    --format '%{window-id}' 2>/dev/null | head -n1)
  ;;
esac

if [ -n "$window_id" ]; then
  aerospace focus --window-id "$window_id" 2>/dev/null || :
  # `focus` returns once the aerospace server accepts the request, not once
  # macOS has raised the window. Handing the URL over early lands the tab in
  # whichever window the browser still thinks it focused last — the very
  # window we are steering away from. Wait for the raise, up to half a
  # second, then go anyway.
  #
  # Asking aerospace which window it considers focused would be useless
  # here: it answers from the model it just updated, so the wait would
  # always end on the first pass while the raise is still in flight.
  # `lsappinfo front` is macOS' own answer, and only flips once the
  # activation has actually landed.
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    front=$(lsappinfo info -only bundleid "$(lsappinfo front)" 2>/dev/null)
    case "$front" in
    *"\"$1\"") break ;;
    esac
    sleep 0.05
  done
fi

open -b "$1" "$2"
]]

function hs.urlevent.httpCallback(_scheme, _host, _params, fullURL)
  hs.task
    .new("/bin/sh", function(exitCode, _stdout, stderr)
      -- Nothing else surfaces a failure here: once Hammerspoon is the
      -- registered handler, a browser that moved or was uninstalled turns
      -- every link click in every app into a silent no-op.
      if exitCode ~= 0 then
        hs.alert.show(
          "Link open failed: "
            .. ((stderr and stderr ~= "") and stderr or exitCode)
        )
      end
    end, {
      "-c",
      OPEN_LINK,
      "sh",
      BROWSER_BUNDLE_ID,
      fullURL,
    })
    :start()
end
