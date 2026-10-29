-- Loading `hs.ipc` is what makes the `hs` command-line tool able to talk to
-- the running Hammerspoon — without it `hs -c ...` just times out. The CLI
-- itself is a symlink into the app bundle; see README for how it is
-- installed.
require("hs.ipc")

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
-- Claude Code's scratchpads and task outputs: agents link the pages they
-- write there, and a file `open` would run still asks.
table.insert(
  katapult.trusted_paths,
  "/private/tmp/claude-" .. hs.execute("id -u"):gsub("%s", "")
)
windowhints = require("windowhints")
workspacename = require("workspacename")
