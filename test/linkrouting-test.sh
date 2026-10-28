#!/usr/bin/env bash
# Regression tests for how linkrouting opens Katapult links (dot-7h6).
#
# Loads hammerspoon/linkrouting.lua under a stub `hs` that records which
# app each click goes to instead of starting a task, so nothing opens.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LUA=${LUA:-$(command -v lua || command -v luajit)}

"$LUA" - "$ROOT/hammerspoon" <<'LUA'
package.path = arg[1] .. "/?.lua;" .. package.path

local started, answer, asked
hs = {
  urlevent = {},
  focus = function() end,
  dialog = {
    blockAlert = function(_, target)
      asked = target
      return answer
    end,
  },
  task = {
    new = function(_, _, args)
      started = { bundle = args[4], url = args[5] }
      return { start = function() end }
    end,
  },
}
require("linkrouting")

local K = "https://kelvinst.github.io/katapult/#"
local failures = 0

local function click(url, reply)
  started, asked, answer = nil, nil, reply
  hs.urlevent.httpCallback("https", nil, nil, url)
end

local function expect(name, ok)
  print((ok and "ok   " or "FAIL ") .. name)
  if not ok then
    failures = failures + 1
  end
end

click(K .. "obsidian%3A%2F%2Fopen%3Fvault%3DStingdom%26file%3DRoutines")
expect(
  "obsidian:// goes to Obsidian, unwrapped, without asking",
  started.bundle == "md.obsidian"
    and started.url == "obsidian://open?vault=Stingdom&file=Routines"
    and not asked
)

click(K .. "https%3A%2F%2Fexample.com%2Fa%3Fb%3D1")
expect(
  "https:// goes to the browser, unwrapped",
  started.bundle == "com.google.Chrome"
    and started.url == "https://example.com/a?b=1"
    and not asked
)

click(K .. "x-things%3A%2F%2Fshow%3Fid%3Dtoday", "Open")
expect(
  "another scheme asks, then opens",
  asked == "x-things://show?id=today"
    and started.bundle == ""
    and started.url == "x-things://show?id=today"
)

click(K .. "shortcuts%3A%2F%2Frun-shortcut%3Fname%3Dx", "Cancel")
expect("another scheme declined opens nothing", asked and not started)

click(K .. "not%20a%20uri")
expect(
  "a target with no scheme goes to the browser as it came",
  started.bundle == "com.google.Chrome" and started.url == K .. "not%20a%20uri"
)

click("https://example.com/")
expect(
  "a plain link goes to the browser",
  started.bundle == "com.google.Chrome"
    and started.url == "https://example.com/"
)

if failures > 0 then
  print(failures .. " failure(s)")
  os.exit(1)
end
print("all passed")
LUA
