-- Workspace labels. alt-shift-r opens a small prompt in the middle of the
-- focused screen, pre-filled with the focused workspace's label; Enter
-- hands it to `orbit rename-workspace`, which puts it next to the
-- workspace number in the menu bar. An empty label drops it, Esc or
-- clicking away leaves everything as it was.
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

-- Live state while the prompt is up, held on the module table so nothing
-- is collected mid-use (see init.lua).
M.prompt = nil
M.content = nil
M.task = nil

-- The window focused when the prompt opened; a cancel hands focus back to
-- it through aerospace, which keeps its own idea of the focused node.
local origin = nil

local function shell(cmd)
  local out = hs.execute(PATH_PREFIX .. cmd)
  return (out or ""):gsub("%s+$", "")
end

local function htmlEscape(s)
  return (
    s:gsub("&", "&amp;")
      :gsub("<", "&lt;")
      :gsub(">", "&gt;")
      :gsub('"', "&quot;")
  )
end

local function close()
  if M.prompt then
    M.prompt:delete()
    M.prompt = nil
  end
  M.content = nil
end

local function cancel()
  close()
  if origin then
    hs.execute(PATH_PREFIX .. "aerospace focus --window-id " .. origin)
  end
end

local function submit(label)
  close()
  -- Through `sh -c` with the label as "$1", so nothing typed is ever
  -- parsed as shell.
  M.task = hs.task.new("/bin/sh", nil, {
    "-c",
    PATH_PREFIX .. 'orbit rename-workspace "$1"',
    "sh",
    label,
  })
  M.task:start()
end

local function page(workspace, label)
  return [[
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
</style></head><body>
  <span>]] .. htmlEscape(workspace) .. [[</span>
  <input id="label" value="]] .. htmlEscape(label) .. [["
         placeholder="label" autofocus>
<script>
  const input = document.getElementById("label");
  const send = (msg) => webkit.messageHandlers.workspacename.postMessage(msg);
  input.select();
  input.addEventListener("keydown", (e) => {
    if (e.key === "Enter") send({ action: "submit", label: input.value });
    if (e.key === "Escape") send({ action: "cancel" });
  });
  window.addEventListener("blur", () => send({ action: "cancel" }));
</script>
</body></html>]]
end

function M.show()
  if M.prompt then
    return
  end

  local current = shell("aerospace list-workspaces --focused")
  local position, rest = current:match("^(%d+)(.*)$")
  if not position then
    -- Nothing to keep a number for (splash, or a workspace named some
    -- other way); orbit would refuse it anyway.
    return
  end
  -- orbit spells the gap, and every space in a label, as U+2800 (see
  -- `orbit rename-workspace help`); the prompt shows plain spaces.
  local label = rest:gsub("^" .. GAP, ""):gsub(GAP, " ")
  origin = shell("aerospace list-windows --focused --format '%{window-id}'")
  if origin == "" then
    origin = nil
  end

  local win = hs.window.focusedWindow()
  local screen = (win and win:screen() or hs.screen.mainScreen()):frame()
  local rect = hs.geometry.rect(
    screen.x + (screen.w - PROMPT_W) / 2,
    screen.y + (screen.h - PROMPT_H) / 2,
    PROMPT_W,
    PROMPT_H
  )

  M.content = hs.webview.usercontent.new("workspacename")
  M.content:setCallback(function(msg)
    -- The prompt losing focus as it closes sends a late cancel; a prompt
    -- already gone has nothing left to answer.
    if not M.prompt then
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
    .new(rect, { developerExtrasEnabled = false }, M.content)
    :windowStyle({ "borderless" })
    :transparent(true)
    :allowTextEntry(true)
    :level(hs.drawing.windowLevels.modalPanel)
    :html(page(position, label))
    :show()
  -- Key focus, so typing lands in the prompt and not the window under it.
  hs.focus()
  M.prompt:hswindow():focus()
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
  -- Out of the tap's callback: the prompt runs shell lookups first, and a
  -- slow tap callback gets the tap disabled by macOS.
  hs.timer.doAfter(0, M.show)
  return true
end

M.trigger = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, onTrigger)
M.trigger:start()

return M
