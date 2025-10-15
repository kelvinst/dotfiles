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
    { "<leader>tob", "yob", desc = "Toggle [b]ackground" },
    { "<leader>toc", "yoc", desc = "Toggle [c]ursorline" },
    { "<leader>tod", "yod", desc = "Toggle [d]iff" },
    { "<leader>toe", "yot", desc = "Toggle [e]nd of line (colorcolumn)" },
    { "<leader>toh", "yoh", desc = "Toggle [h]lsearch" },
    { "<leader>toi", "yoi", desc = "Toggle [i]gnorecase" },
    { "<leader>tol", "yol", desc = "Toggle [l]ist" },
    { "<leader>ton", "yon", desc = "Toggle [n]umber", remap = false },
    { "<leader>tor", "yor", desc = "Toggle [r]elativenumber" },
    { "<leader>tos", "yos", desc = "Toggle [s]pell" },
    { "<leader>tou", "you", desc = "Toggle c[u]rsorcolumn" },
    { "<leader>tov", "yov", desc = "Toggle [v]irtualedit" },
    { "<leader>tow", "yow", desc = "Toggle [w]rap" },
    {
      "<leader>tox",
      "yox",
      desc = "Toggle [x]hairs (cursorline and cursorcolumn)",
    },
    {
      "<leader>tq",
      toggle_quickfix,
      desc = "Toggle [q]uickfix",
      silent = true,
    },
    {
      "<leader>tx",
      function()
        os.execute("<cmd>![ -x % ] && chmod -x % || chmod +x %")
      end,
      desc = "Toggle e[x]ecutable",
    },
  },
  config = function()
    -- Configure which-key with the unimpaired mappings
    require("which-key").add({
      { "<leader>t", group = "[T]oggle" },
      { "<leader>to", group = "Toggle [o]ptions" },
    })
  end,
}
