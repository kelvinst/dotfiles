-- Set textwidth for automatic wrapping at 72 characters (common convention)
vim.api.nvim_create_autocmd("BufModifiedSet", {
  callback = function()
    vim.opt_local.textwidth = 72
  end,
})
