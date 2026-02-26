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
      { "<leader><space>", group = "Hop" }, -- hop.lua
      { "<leader>a", group = "AI", mode = "nv" }, -- 99.lua
      { "<leader>b", group = "Buffers" }, -- bufferline.lua
      { "<leader>bt", group = "Tabs" }, -- bufferline.lua
      { "<leader>c", group = "Command" }, -- keymaps.lua
      { "<leader>e", group = "Error diagnostics" }, -- keymaps.lua
      { "<leader>f", group = "Files" }, -- keymaps.lua
      { "<leader>fa", group = "Alternate" }, -- projectionist.lua
      { "<leader>ft", group = "Temporary files" }, -- keymaps.lua
      { "<leader>g", group = "Git" }, -- neogit.lua, gitsigns.lua
      { "<leader>gh", group = "GitHub" }, -- gitlinker.lua, octo.lua
      { "<leader>ghi", group = "Issues" }, -- octo.lua
      { "<leader>ghp", group = "Pull Requests" }, -- octo.lua
      { "<leader>gx", group = "Execute Hooks" }, -- neogit.lua
      { "<leader>l", group = "LSP" }, -- lspconfig.lua
      { "<leader>m", group = "Make" }, -- dispatch.lua
      { "<leader>n", group = "Notifications" }, -- noice.lua
      { "<leader>p", group = "Pick" }, -- telescope.lua
      { "<leader>s", group = "Sessions" }, -- possession.lua
      { "<leader>t", group = "Toggle" }, -- unimpaired.lua
      { "<leader>to", group = "Toggle options" }, -- unimpaired.lua
      { "<leader>v", group = "Vim" }, -- keymaps.lua
      { "<leader>y", group = "Yank" }, -- keymaps.lua
      { "<leader>'", group = "Start" }, -- dispatch.lua
      { "<leader>`", group = "Dispatch" }, -- dispatch.lua
      { "m", group = "Make / Set mark" }, -- dispatch.lua
      { "s", group = "Surround" }, -- mini.lua
      { "'", group = "Start / Go to mark" }, -- dispatch.lua
      { "`", group = "Dispatch / Go to mark" }, -- dispatch.lua
    },

    triggers = {
      { "<auto>", mode = "nxsoi" },
      { "s", mode = "nv" },
    },
  },
}
