return { -- Useful plugin to show you pending keybinds.
  "folke/which-key.nvim",
  event = "VimEnter", -- Sets the loading event to 'VimEnter'
  opts = {
    preset = "helix",

    win = {
      no_overlap = false,
      width = 60,
      col = vim.fn.winwidth(0) / 2 - 30,
      row = 12,
    },

    icons = {
      mappings = true, -- I have nerfont installed, so I want to use those icons
    },

    -- Existing keybindings
    spec = {
      { "<leader><space>", group = "Hop" },
      { "<leader>a", group = "[A]I", mode = "nv" },
      { "<leader>c", group = "[C]ommand" },
      { "<leader>e", group = "[E]rror diagnostics" },
      { "<leader>f", group = "[F]iles" },
      { "<leader>g", group = "[G]it" },
      { "<leader>n", group = "[N]otifications" },
      { "<leader>s", group = "[S]essions" },
      { "<leader>v", group = "[V]im" },
      { "<leader>y", group = "[Y]ank" },
    },

    triggers = {
      { "<auto>", mode = "nxsoi" },
      { "s", mode = "nv" },
    },
  },
}
