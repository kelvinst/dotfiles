return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>gg", vim.cmd.Neogit, desc = "[G]it Status" },
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
      kind = "floating",
      remember_settings = false,
      commit_editor = {
        kind = "tab",
        staged_diff_split_kind = "auto",
      },
      commit_view = {
        kind = "tab",
        verify_commit = vim.fn.executable("gpg") == 1,
      },
      integrations = {
        telescope = true,
        diffview = true,
      },
      mappings = {
        status = {
          ["<esc>"] = "Close",
        },
      },
    })

    require("which-key").add({
      { "<leader>gh", group = "[H]ooks" },
    })
  end,
}
