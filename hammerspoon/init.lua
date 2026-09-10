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
monitors = require("monitors")
linkrouting = require("linkrouting")
