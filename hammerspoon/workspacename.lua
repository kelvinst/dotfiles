-- Workspace labels. alt-shift-r opens a small prompt in the middle of the
-- focused screen, pre-filled with the focused workspace's label; Enter
-- hands it to `orbit rename-workspace`, which puts it next to the
-- workspace number in the menu bar, and a spinner shows until it's done.
-- An empty label drops it, Esc or clicking away leaves everything as it
-- was.
local M = {}

local HOTKEY_MODS = { alt = true, shift = true }
local HOTKEY_KEY = "r"

local GAP = "\u{2800}"

local PROMPT_W = 420
local PROMPT_H = 64

-- Same bare-launchd-PATH problem as monitors.lua: neither `orbit` nor
-- `aerospace` is on it.
local PATH_PREFIX =
  'PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH" '

-- Held on the module table so nothing is collected while in use (see
-- init.lua).
M.prompt = nil
M.content = nil
M.task = nil
M.lookup = nil

-- The window focused when the prompt opened; a cancel hands focus back to
-- it through aerospace, which keeps its own idea of the focused node.
local origin = nil

-- Set from Enter until orbit is done; the prompt shows a spinner and
-- takes no more input meanwhile.
local applying = false

local function hide()
  applying = false
  M.prompt:hide()
end

local function cancel()
  hide()
  -- In the background: aerospace waits on Hammerspoon's own windows while
  -- it moves focus, so a blocking hs.execute here stalled both for 3s, and
  -- the prompt with them.
  if origin then
    M.task = hs.task.new("/bin/sh", nil, {
      "-c",
      PATH_PREFIX .. 'aerospace focus --window-id "$1"',
      "sh",
      origin,
    })
    M.task:start()
  end
end

local function submit(label)
  applying = true
  M.prompt:evaluateJavaScript("busy()")
  -- Through `sh -c` with the label as "$1", so nothing typed is ever
  -- parsed as shell. orbit puts focus back itself.
  M.task = hs.task.new("/bin/sh", hide, {
    "-c",
    PATH_PREFIX .. 'orbit rename-workspace "$1"',
    "sh",
    label,
  })
  M.task:start()
end

local PAGE = [[
<!doctype html>
<html><head><meta charset="utf-8"><style>
  html, body { margin: 0; height: 100%; background: transparent; }
  body { display: flex; align-items: center; gap: 12px; padding: 0 16px;
         box-sizing: border-box; border-radius: 12px;
         background: #1e2028;
         border: 1px solid rgba(225, 227, 228, 0.35);
         font: 20px -apple-system, system-ui, sans-serif; color: #e1e3e4; }
  span { opacity: 0.6; font-variant-numeric: tabular-nums; }
  input { flex: 1; font: inherit; color: inherit; background: transparent;
          border: 0; outline: 0; }
  input:disabled { opacity: 0.5; }
  #spin { display: none; width: 18px; height: 18px; border-radius: 50%;
          border: 2px solid rgba(225, 227, 228, 0.25);
          border-top-color: #e1e3e4; animation: spin 0.7s linear infinite; }
  body.busy #spin { display: block; }
  @keyframes spin { to { transform: rotate(360deg); } }
</style></head><body>
  <span id="position"></span>
  <input id="label" placeholder="label">
  <div id="spin"></div>
<script>
  const input = document.getElementById("label");
  const send = (msg) => webkit.messageHandlers.workspacename.postMessage(msg);
  // The prompt opens empty and is filled once aerospace answers, which
  // can take seconds; whatever was typed by then wins over the fill.
  let edited = false;
  input.addEventListener("input", () => { edited = true; });
  function open(position, label) {
    document.body.classList.remove("busy");
    document.getElementById("position").textContent = position;
    input.disabled = false;
    if (position === "") edited = false;
    if (!edited) {
      input.value = label;
      input.select();
    }
    input.focus();
  }
  function busy() {
    document.body.classList.add("busy");
    input.disabled = true;
  }
  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter") send({ action: "submit", label: input.value });
    if (e.key === "Escape") send({ action: "cancel" });
  });
  window.addEventListener("blur", () => send({ action: "cancel" }));
</script>
</body></html>]]

-- Built once, up front, and only shown and hidden after: creating a
-- webview and loading its page is what made the prompt slow to appear.
M.content = hs.webview.usercontent.new("workspacename")
M.content:setCallback(function(msg)
  -- A hidden prompt's late blur, or Esc while orbit is still applying,
  -- has nothing left to answer.
  if applying or not M.prompt:isVisible() then
    return
  end
  local body = msg.body or {}
  if body.action == "submit" then
    submit(body.label or "")
  else
    cancel()
  end
end)

M.prompt = hs.webview
  .new(
    { x = 0, y = 0, w = PROMPT_W, h = PROMPT_H },
    { developerExtrasEnabled = false },
    M.content
  )
  :windowStyle({ "borderless" })
  :transparent(true)
  :allowTextEntry(true)
  :level(hs.drawing.windowLevels.modalPanel)
  :html(PAGE)

function M.show()
  if applying or M.prompt:isVisible() then
    return
  end

  -- Read before the prompt takes focus, which would answer with the
  -- prompt itself. AeroSpace window ids are the CGWindowIDs hs.window
  -- gives.
  local focused = hs.window.focusedWindow()
  origin = focused and tostring(focused:id()) or nil

  -- The main screen is the one holding the focused window.
  local screen = hs.screen.mainScreen():frame()
  M.prompt:frame({
    x = screen.x + (screen.w - PROMPT_W) / 2,
    y = screen.y + (screen.h - PROMPT_H) / 2,
    w = PROMPT_W,
    h = PROMPT_H,
  })
  M.prompt:show()
  -- Key focus, so typing lands in the prompt and not the window under it.
  -- Not `hswindow():focus()`: finding the prompt's hs.window goes through
  -- Accessibility and took 3s.
  hs.focus()
  M.prompt:bringToFront()
  M.prompt:evaluateJavaScript('open("", "")')

  -- Filled in once aerospace answers, in the background like cancel's
  -- refocus: right after a cancel aerospace can take 3s to answer while
  -- it settles focus, and a blocking lookup held the prompt back that
  -- long.
  M.lookup = hs.task.new("/bin/sh", function(_, out)
    if not M.prompt:isVisible() or applying then
      return
    end
    local current = (out or ""):match("^([^\n]*)")
    local position, rest = (current or ""):match("^(%d+)(.*)$")
    if not position then
      -- Nothing to keep a number for (splash, or a workspace named some
      -- other way); orbit would refuse it anyway.
      hide()
      return
    end
    -- orbit spells the gap, and every space in a label, as U+2800 (see
    -- `orbit rename-workspace help`); the prompt shows plain spaces.
    local label = rest:gsub("^" .. GAP, ""):gsub(GAP, " ")
    M.prompt:evaluateJavaScript(
      "open(" .. hs.json.encode({ position, label }):sub(2, -2) .. ")"
    )
  end, { "-c", PATH_PREFIX .. "aerospace list-workspaces --focused" })
  M.lookup:start()
end

-- An event tap rather than hs.hotkey, for the reason windowhints.lua gives.
-- Keep alt-shift-r unbound in aerospace so it reaches Hammerspoon.
local function onTrigger(event)
  if hs.keycodes.map[event:getKeyCode()] ~= HOTKEY_KEY then
    return false
  end
  local flags = event:getFlags()
  for _, mod in ipairs({ "cmd", "alt", "shift", "ctrl" }) do
    if (flags[mod] or false) ~= (HOTKEY_MODS[mod] or false) then
      return false
    end
  end
  -- Out of the tap's callback: showing the prompt takes a moment, and
  -- a slow tap callback gets the tap disabled by macOS.
  hs.timer.doAfter(0, M.show)
  return true
end

M.trigger = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, onTrigger)
M.trigger:start()

return M
