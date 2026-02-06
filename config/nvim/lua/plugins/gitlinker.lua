return {
  "linrongbin16/gitlinker.nvim",
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
  opts = {},
}
