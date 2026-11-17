-- Loading `hs.ipc` is what makes the `hs` command-line tool able to talk to
-- the running Hammerspoon — without it `hs -c ...` just times out. The CLI
-- itself is a symlink into the app bundle; see README for how it is
-- installed.
require("hs.ipc")
-- Load up front what `hs -c` snippets use (bin/kvm, bin/orbit). Loaded
-- lazily inside a request, an extension prints "Loading extension" back to
-- the client, which re-enters hs.ipc until the Lua stack overflows.
for _, name in ipairs({
  "application",
  "axuielement",
  "mouse",
  "screen",
  "timer",
  "window",
}) do
  require("hs." .. name)
end

-- Globals on purpose. Both modules hold live objects — a screen watcher, a
-- pending timer, a running task — that Lua collects as soon as nothing
-- references them, and a collected watcher or timer stops firing silently.
-- A `local` here goes out of scope when this chunk returns; a global
-- outlives it.
-- Monitor switching is off for now: it isn't working well, and it'll be
-- revisited later (dot-nhy). Uncomment to turn it back on.
-- monitors = require("monitors")
-- Installed from kelvinst/katapult by `make install`, not kept here.
katapult = require("katapult-spoon")
windowhints = require("windowhints")
-- Double-tap Control/Command/Option for Return/Space/Backspace; replaces
-- the old Karabiner rules (dot-p45).
doubletap = require("doubletap").start()
