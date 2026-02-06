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
    { "<leader>ghpo", ":Octo pr browser<cr>", desc = "Open PR" },
    { "<leader>ghpm", ":Octo pr merge<cr>", desc = "Merge PR" },
    { "<leader>ghpk", ":Octo pr checkout<cr>", desc = "Checkout PR" },
    { "<leader>ghic", ":Octo issue create<cr>", desc = "Create Issue" },
    { "<leader>ghil", ":Octo issue list<cr>", desc = "List Issues" },
    { "<leader>ghio", ":Octo issue browser<cr>", desc = "Open Issue" },
  },
  opts = {
    picker = "telescope",
  },
}
