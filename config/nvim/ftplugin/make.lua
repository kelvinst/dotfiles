-- Set Makefile tab settings when opening a buffer
-- NOTE: It has to be on BufWinEnter, because checkmake overrides tab settings
-- when loading
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})
