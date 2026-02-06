return {
  "linrongbin16/gitlinker.nvim",
  dependencies = { "folke/which-key.nvim" },
  keys = {
    {
      "<leader>gho",
      ":GitLink!<cr>",
      mode = { "n", "v" },
      desc = "Open in GitHub",
    },
    {
      "<leader>ghy",
      ":GitLink<cr>",
      mode = { "n", "v" },
      desc = "Copy GitHub link",
    },
  },
  config = function()
    require("gitlinker").setup()
    require("which-key").add({
      { "<leader>gh", group = "GitHub" },
    })
  end,
}
