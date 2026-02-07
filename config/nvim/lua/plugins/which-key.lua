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
      { "<leader>b", group = "Buffers" },
      { "<leader>bt", group = "Tabs" },
      { "<leader>c", group = "Command" },
      { "<leader>d", group = "Dispatch" },
      { "<leader>e", group = "Error diagnostics" },
      { "<leader>f", group = "Files" },
      { "<leader>fa", group = "Alternate" },
      { "<leader>ft", group = "Temporary files" },
      { "<leader>g", group = "Git" },
      { "<leader>gh", group = "GitHub" },
      { "<leader>ghi", group = "Issues" },
      { "<leader>ghp", group = "Pull Requests" },
      { "<leader>gx", group = "Execute Hooks" },
      { "<leader>l", group = "LSP" },
      { "<leader>n", group = "Notifications" },
      { "<leader>p", group = "Pick" },
      { "<leader>s", group = "Sessions" },
      { "<leader>t", group = "Toggle" },
      { "<leader>to", group = "Toggle options" },
      { "<leader>v", group = "Vim" },
      { "<leader>y", group = "Yank" },
      { "m", group = "Make / Set mark" },
      { "`", group = "Dispatch / Go to mark" },
      { "'", group = "Start / Go to mark" },
      { "s", group = "Surround" },
    },

    triggers = {
      { "<auto>", mode = "nxsoi" },
      { "s", mode = "nv" },
    },
  },
}
