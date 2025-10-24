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
    { "<leader>tob", "yob", desc = "Toggle background" },
    { "<leader>toc", "yoc", desc = "Toggle cursorline" },
    { "<leader>tod", "yod", desc = "Toggle diff" },
    { "<leader>toe", "yot", desc = "Toggle end of line (colorcolumn)" },
    { "<leader>toh", "yoh", desc = "Toggle hlsearch" },
    { "<leader>toi", "yoi", desc = "Toggle ignorecase" },
    { "<leader>tol", "yol", desc = "Toggle list" },
    { "<leader>ton", "yon", desc = "Toggle number", remap = false },
    { "<leader>tor", "yor", desc = "Toggle relativenumber" },
    { "<leader>tos", "yos", desc = "Toggle spell" },
    { "<leader>tou", "you", desc = "Toggle cursorcolumn" },
    { "<leader>tov", "yov", desc = "Toggle virtualedit" },
    { "<leader>tow", "yow", desc = "Toggle wrap" },
    {
      "<leader>tox",
      "yox",
      desc = "Toggle xhairs (cursorline and cursorcolumn)",
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
  config = function()
    -- Configure which-key with the unimpaired mappings
    require("which-key").add({
      { "<leader>t", group = "Toggle" },
      { "<leader>to", group = "Toggle options" },
    })
  end,
}
