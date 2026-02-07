local function toggle_quickfix()
  if
    vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), "v:val.quickfix")) == 1
  then
    vim.cmd("bot copen")
  else
    vim.cmd("cclose")
  end
end

return {
  "tpope/vim-unimpaired",
  event = "VimEnter",
  keys = {
    { "<leader>tob", "<Plug>(unimpaired-toggle)b", desc = "Toggle background" },
    { "<leader>toc", "<Plug>(unimpaired-toggle)c", desc = "Toggle cursorline" },
    { "<leader>tod", "<Plug>(unimpaired-toggle)d", desc = "Toggle diff" },
    {
      "<leader>toe",
      "<Plug>(unimpaired-toggle)t",
      desc = "Toggle end of line (colorcolumn)",
    },
    { "<leader>toh", "<Plug>(unimpaired-toggle)h", desc = "Toggle hlsearch" },
    { "<leader>toi", "<Plug>(unimpaired-toggle)i", desc = "Toggle ignorecase" },
    { "<leader>tol", "<Plug>(unimpaired-toggle)l", desc = "Toggle list" },
    { "<leader>ton", "<Plug>(unimpaired-toggle)n", desc = "Toggle number" },
    {
      "<leader>tor",
      "<Plug>(unimpaired-toggle)r",
      desc = "Toggle relativenumber",
    },
    { "<leader>tos", "<Plug>(unimpaired-toggle)s", desc = "Toggle spell" },
    {
      "<leader>tou",
      "<Plug>(unimpaired-toggle)u",
      desc = "Toggle cursorcolumn",
    },
    {
      "<leader>tov",
      "<Plug>(unimpaired-toggle)v",
      desc = "Toggle virtualedit",
    },
    { "<leader>tow", "<Plug>(unimpaired-toggle)w", desc = "Toggle wrap" },
    {
      "<leader>tox",
      "<Plug>(unimpaired-toggle)x",
      desc = "Toggle crosshairs (cursorline and cursorcolumn)",
    },
    {
      "<leader>tq",
      toggle_quickfix,
      desc = "Toggle quickfix",
      silent = true,
    },
    {
      "<leader>tx",
      function()
        os.execute("<cmd>![ -x % ] && chmod -x % || chmod +x %")
      end,
      desc = "Toggle executable",
    },
  },
}
