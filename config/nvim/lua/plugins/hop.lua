local function with_popup(label, cmd)
  return function()
    local msg = "  " .. label .. "  "
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { msg })
    local win = vim.api.nvim_open_win(buf, false, {
      relative = "editor",
      width = #msg,
      height = 1,
      col = math.floor((vim.o.columns - #msg) / 2),
      row = math.floor((vim.o.lines - 1) / 2),
      style = "minimal",
      border = "rounded",
      focusable = false,
      zindex = 100,
    })

    vim.cmd.VimadeDisable()
    pcall(cmd)
    vim.cmd.VimadeEnable()

    pcall(vim.api.nvim_win_close, win, true)
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
end

return { -- Easily jump around in your file
  "smoka7/hop.nvim",
  event = "VimEnter",
  version = "v2.7.2",
  keys = {
    {
      "<leader><space>",
      with_popup("Hop to char", vim.cmd.HopChar1),
      desc = "Hop to a char",
    },
    {
      "<leader>h/",
      with_popup("Hop pattern", vim.cmd.HopPattern),
      desc = "Search like /",
    },
    {
      "<leader>h1",
      with_popup("Hop 1 char", vim.cmd.HopChar1),
      desc = "1 Char",
    },
    {
      "<leader>h2",
      with_popup("Hop 2 chars", vim.cmd.HopChar2),
      desc = "2 Char",
    },
    { "<leader>ha", vim.cmd.HopAnywhere, desc = "Anywhere" },
    { "<leader>hh", vim.cmd.HopWord, desc = "Default (1 char)" },
    { "<leader>hl", vim.cmd.HopLine, desc = "Line" },
    { "<leader>ht", vim.cmd.HopNodes, desc = "Treesiter nodes" },
    { "<leader>hw", vim.cmd.HopWord, desc = "Word" },
  },
  config = function()
    local hop = require("hop")

    hop.setup({ multi_windows = true, quit_key = "<leader>" })

    vim.keymap.set({ "n", "v" }, "<leader>hn", function()
      ---@diagnostic disable-next-line: missing-fields
      hop.hint_patterns({}, vim.fn.getreg("/"))
    end, { desc = "Next pattern (based on what was searched on /)" })
  end,
}
