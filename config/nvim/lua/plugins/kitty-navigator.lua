-- `pass_keys.py` / `navigate_kitty.py` are not copied via the plugin's `build`
-- step — they live in our dotfiles (config/kitty) and are installed by the
-- repo Makefile. Letting Lazy `cp` the upstream originals would clobber the
-- orbit fallback we added in `pass_keys.py`.
--
-- The plugin's own `M.navigate` handles vim split → kitty pane. We replace it
-- with a three-tier chain so ctrl-hjkl keeps traveling outward once kitty has
-- no neighboring pane either:
--   1. `wincmd <dir>` within vim
--   2. `kitty @ focus-window --match neighbor:<dir>`
--   3. `orbit focus --boundaries-action sibling-workspace <dir>`
return {
  "MunsMan/kitty-navigator.nvim",
  cond = (vim.env.TMUX == nil and vim.env.KITTY_PID ~= nil),
  config = function()
    local kn = require("kitty-navigator")
    local kitty_dir = { h = "left", j = "bottom", k = "top", l = "right" }
    local aero_dir = { h = "left", j = "down", k = "up", l = "right" }
    local orbit = vim.fn.expand("~/.local/bin/orbit")

    function kn.navigate(direction)
      if vim.fn.winnr() ~= vim.fn.winnr("1" .. direction) then
        vim.api.nvim_command("wincmd " .. direction)
        return
      end

      -- `kitty @ focus-window` returns 0 even with no matches, so probe with
      -- `kitty @ ls` first — it exits non-zero on an empty match.
      local match = "neighbor:" .. kitty_dir[direction]
      vim.fn.system({ "kitty", "@", "ls", "--match", match })
      if vim.v.shell_error == 0 then
        vim.fn.system({ "kitty", "@", "focus-window", "--match", match })
        return
      end

      vim.fn.jobstart({
        orbit,
        "focus",
        "--boundaries-action",
        "sibling-workspace",
        aero_dir[direction],
      })
    end
  end,
  keys = {
    {
      "<C-h>",
      function()
        require("kitty-navigator").navigateLeft()
      end,
      desc = "Move left a Split",
      mode = { "n" },
    },
    {
      "<C-j>",
      function()
        require("kitty-navigator").navigateDown()
      end,
      desc = "Move down a Split",
      mode = { "n" },
    },
    {
      "<C-k>",
      function()
        require("kitty-navigator").navigateUp()
      end,
      desc = "Move up a Split",
      mode = { "n" },
    },
    {
      "<C-l>",
      function()
        require("kitty-navigator").navigateRight()
      end,
      desc = "Move right a Split",
      mode = { "n" },
    },
  },
}
