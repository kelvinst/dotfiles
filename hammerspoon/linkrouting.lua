-- macOS hands a clicked link to Chrome, and Chrome drops the new tab into
-- whichever of its windows it focused last. That window is often on another
-- aerospace workspace — or another monitor — so clicking a link in
-- kitty/Claude yanks the whole desktop somewhere else. Route http(s)
-- through here instead: focus the Chrome window that lives on the *focused*
-- workspace first, so Chrome's "last focused window" is the one in front of
-- us when the URL lands. With no Chrome window on this workspace at all,
-- open a new one here rather than letting Chrome pull us over to wherever
-- its last window lives.
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
local OBSIDIAN_BUNDLE_ID = "md.obsidian"

-- Katapult (kelvinst/katapult) is a one-page https redirector to any scheme,
-- the target URL-encoded after the `#`: chat apps only follow https links, so
-- vault notes are linked through it. For an Obsidian note the page has
-- nothing to add here: unwrap it and skip the browser tab altogether.
local KATAPULT_PREFIX = "https://kelvinst.github.io/katapult/#"

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

  open -b "$1" "$2"
else
  # Nothing of the browser's on this workspace. Plain `open -b` would hand
  # the URL to the browser's last-focused window — on whatever workspace or
  # monitor that happens to be — and drag us there. Ask for a brand new
  # window instead: aerospace puts newly opened windows on the focused
  # workspace, so the tab lands where we are looking.
  #
  # `-n` starts a fresh instance; a browser already running takes the
  # command line off it and opens the window itself, so this is one new
  # window either way, not a second copy of the app.
  open -n -b "$1" --args --new-window "$2"
fi
]]

-- Obsidian's own handler raises whichever of its windows was focused last —
-- often on another workspace or monitor, the very jump OPEN_LINK avoids for
-- the browser. Same answer: with an Obsidian window on the focused workspace,
-- focus it and open the note there in a new tab; with none, open the note in
-- a new pop-out window (or, with none open at all, its main one), which
-- aerospace puts on the focused workspace. $1 is the bundle id, $2 the
-- obsidian:// URL.
local OPEN_OBSIDIAN = [[
exec </dev/null

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Our links carry their own paneType; this script picks it instead.
url=$(printf '%s' "$2" | sed -E 's/&paneType=[^&]*//')

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
  # Wait for the raise before handing the URL over, as OPEN_LINK does:
  # Obsidian opens the tab in the window it last saw focused.
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    front=$(lsappinfo info -only bundleid "$(lsappinfo front)" 2>/dev/null)
    case "$front" in
    *"\"$1\"") break ;;
    esac
    sleep 0.05
  done

  open -g "$url&paneType=tab"
else
  # `-g` keeps macOS from activating Obsidian, which would raise its last
  # window and drag the focus — and the new pop-out — over there.
  before=$(aerospace list-windows --monitor all --app-bundle-id "$1" \
    --format '%{window-id}' 2>/dev/null)
  # With no Obsidian window anywhere, its main window is the new one; asking
  # for a pop-out too would open the note twice.
  if [ -n "$before" ]; then
    pane=window
  else
    pane=tab
  fi
  open -g "$url&paneType=$pane"

  # Focus the pop-out once it shows up, up to two seconds.
  for _ in $(seq 40); do
    new=$(aerospace list-windows --monitor all --app-bundle-id "$1" \
      --format '%{window-id}' 2>/dev/null |
      grep -vxF "$before" | head -n1)
    if [ -n "$new" ]; then
      aerospace focus --window-id "$new" 2>/dev/null || :
      break
    fi
    sleep 0.05
  done
fi
]]

-- Decodes %XX escapes; `+` stays as it is, since a fragment is no form.
local function percent_decode(text)
  return (
    text:gsub("%%(%x%x)", function(hex)
      return string.char(tonumber(hex, 16))
    end)
  )
end

-- The script and arguments that open `url`: a Katapult link to obsidian://
-- goes straight to OPEN_OBSIDIAN; everything else, other Katapult targets
-- included, goes to the browser, where the page asks before launching an app.
local function opener(url)
  if url:sub(1, #KATAPULT_PREFIX) == KATAPULT_PREFIX then
    local target = percent_decode(url:sub(#KATAPULT_PREFIX + 1))
    if target:match("^obsidian://") then
      return OPEN_OBSIDIAN, OBSIDIAN_BUNDLE_ID, target
    end
  end
  return OPEN_LINK, BROWSER_BUNDLE_ID, url
end

-- Held for the same reason `monitors` holds its sync task: a task that gets
-- collected mid-run never calls back, so the link would never open and the
-- alert below would never fire — a click that leaves no trace at all. The
-- `open` above waits up to half a second for the raise, which is plenty of
-- room for a collection to land. A table rather than a single slot,
-- because clicks overlap and one slot would drop the run still going.
local running = {}

function hs.urlevent.httpCallback(_scheme, _host, _params, fullURL)
  local script, bundle_id, url = opener(fullURL)
  local task
  task = hs.task.new("/bin/sh", function(exitCode, _stdout, stderr)
    -- Nothing else surfaces a failure here: once Hammerspoon is the
    -- registered handler, a browser that moved or was uninstalled turns
    -- every link click in every app into a silent no-op.
    if exitCode ~= 0 then
      hs.alert.show(
        "Link open failed: "
          .. ((stderr and stderr ~= "") and stderr or exitCode)
      )
    end

    running[task] = nil
  end, {
    "-c",
    script,
    "sh",
    bundle_id,
    url,
  })

  running[task] = true
  task:start()
end

return { running = running }
