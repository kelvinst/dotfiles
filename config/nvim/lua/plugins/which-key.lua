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
      { "<leader>a", group = "AI", mode = "nv" },
      { "<leader>c", group = "Command" },
      { "<leader>e", group = "Error diagnostics" },
      { "<leader>f", group = "Files" },
      { "<leader>ft", group = "Temporary files" },
      { "<leader>g", group = "Git" },
      { "<leader>n", group = "Notifications" },
      { "<leader>s", group = "Sessions" },
      { "<leader>v", group = "Vim" },
      { "<leader>y", group = "Yank" },
    },

    triggers = {
      { "<auto>", mode = "nxsoi" },
      { "s", mode = "nv" },
    },
  },
}
