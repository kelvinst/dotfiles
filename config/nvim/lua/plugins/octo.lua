return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  keys = {
    { "<leader>ghpc", ":Octo pr create<cr>", desc = "Create PR" },
    { "<leader>ghpl", ":Octo pr list<cr>", desc = "List PRs" },
    { "<leader>ghpm", ":Octo pr merge<cr>", desc = "Merge PR" },
    { "<leader>ghpk", ":Octo pr checkout<cr>", desc = "Checkout PR" },
    { "<leader>ghic", ":Octo issue create<cr>", desc = "Create Issue" },
    { "<leader>ghil", ":Octo issue list<cr>", desc = "List Issues" },
    { "<leader>ghs", ":Octo search<cr>", desc = "Search" },
  },
  config = function()
    require("octo").setup({
      picker = "telescope",
    })
    require("which-key").add({
      { "<leader>ghp", group = "Pull Requests" },
      { "<leader>ghi", group = "Issues" },
    })
  end,
}
