return {
  "akinsho/bufferline.nvim",
  event = "VimEnter",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  keys = {
    { "]b", vim.cmd.BufferLineCycleNext, desc = "Next Buffer" },
    { "[b", vim.cmd.BufferLineCyclePrev, desc = "Previous Buffer" },
    { "gb", vim.cmd.BufferLineCycleNext, desc = "Next Buffer" },
    { "gB", vim.cmd.BufferLineCyclePrev, desc = "Previous Buffer" },
    { "]t", "gt", desc = "Next Tab" },
    { "[t", "gT", desc = "Previous Tab" },
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
      desc = "Pick",
    },
    { "<leader>bm", vim.cmd.BufferLineCycleNext, desc = "Move" },
    { "<leader>bc", ClearInvisibleBuffers, desc = "Clear invisible buffers" },
    { "<leader>bd", vim.cmd.bd, desc = "Delete current buffer" },
    { "<leader>br", ":BufferLineTabRename ", desc = "Rename tab" },
  },
  config = function()
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
