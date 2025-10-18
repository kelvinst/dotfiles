return {
  "akinsho/bufferline.nvim",
  event = "VimEnter",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  keys = {
    { "]b", vim.cmd.BufferLineCycleNext, desc = "Next [B]uffer" },
    { "[b", vim.cmd.BufferLineCyclePrev, desc = "Previous [B]uffer" },
    { "gb", vim.cmd.BufferLineCycleNext, desc = "Next [B]uffer" },
    { "gB", vim.cmd.BufferLineCyclePrev, desc = "Previous [B]uffer" },
    { "]t", "gt", desc = "Next [T]ab" },
    { "[t", "gT", desc = "Previous [T]ab" },
    {
      "<leader>bp",
      function()
        vim.cmd.VimadeFadeActive()

        vim.defer_fn(function()
          pcall(function()
            vim.cmd.BufferLinePick()
          end)

          vim.cmd.VimadeUnfadeActive()
        end, 100)
      end,
      desc = "[P]ick",
    },
    { "<leader>bm", vim.cmd.BufferLineCycleNext, desc = "[M]ove" },
    { "<leader>bc", ClearInvisibleBuffers, desc = "[C]lear invisible buffers" },
    { "<leader>bd", vim.cmd.bd, desc = "[D]elete current buffer" },
    { "<leader>br", ":BufferLineTabRename ", desc = "[R]ename tab" },
  },
  config = function()
    require("which-key").add({
      { "<leader>b", group = "[B]uffers" },
      { "<leader>bt", group = "[T]abs" },
    })

    local bufferline = require("bufferline")
    bufferline.setup({
      options = {
        diagnostics = "nvim_lsp",
        hover = {
          enabled = true,
          delay = 10,
          reveal = { "close" },
        },
        sort_by = "id",
      },
    })
  end,
}
