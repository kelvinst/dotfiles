-- Autoresize my windows when resizing the terminal
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("wincmd =")
  end,
})

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = { "grep", "vimgrep" },
  callback = function()
    vim.cmd("bot copen")
  end,
  desc = "Open quickfix list after grep commands",
})
