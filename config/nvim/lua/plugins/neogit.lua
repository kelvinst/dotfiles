return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
    "folke/which-key.nvim",
  },
  keys = {
    { "<leader>gg", vim.cmd.Neogit, desc = "[G]it Status" },
    { "<leader>gl", vim.cmd.NeogitLogCurrent, desc = "[G]it Status" },
    {
      "<leader>ghc",
      ":Dispatch .git/hooks/pre-commit<CR>",
      desc = "pre-[c]ommit",
    },
    { "<leader>ghp", ":Dispatch .git/hooks/pre-push<CR>", desc = "pre-[p]ush" },
  },
  config = function()
    require("neogit").setup({
      console_timeout = 1000,
      disable_insert_on_commit = true,
      remember_settings = false,
      commit_editor = {
        kind = "tab",
        staged_diff_split_kind = "auto",
      },
      integrations = {
        telescope = true,
        diffview = true,
      },
      mappings = {
        status = {
          ["<esc>"] = "Close",
          ["<C-c>"] = "Close",
          ["ZZ"] = "Close",
        },
      },
    })

    require("which-key").add({
      { "<leader>gh", group = "[H]ooks" },
    })
  end,
}
