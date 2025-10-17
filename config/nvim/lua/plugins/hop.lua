local function without_vimade(cmd)
  return function()
    vim.cmd.VimadeDisable()
    cmd()
    vim.cmd.VimadeEnable()
  end
end

return { -- Easily jump around in your file
  "smoka7/hop.nvim",
  event = "VimEnter",
  version = "v2.7.2",
  keys = {
    {
      "<leader><space><space>",
      without_vimade(vim.cmd.HopChar1),
      desc = "Hop to a char",
    },
    {
      "<leader><space>/",
      without_vimade(vim.cmd.HopPattern),
      desc = "Search like [/]",
    },
    {
      "<leader><space>1",
      without_vimade(vim.cmd.HopChar1),
      desc = "[1] Char",
    },
    {
      "<leader><space>2",
      without_vimade(vim.cmd.HopChar2),
      desc = "[2] Char",
    },
    {
      "<leader><space>a",
      without_vimade(vim.cmd.HopAnywhere),
      desc = "[A]nywhere",
    },
    {
      "<leader><space>h",
      without_vimade(vim.cmd.HopChar1),
      desc = "Default (1 char)",
    },
    { "<leader><space>l", without_vimade(vim.cmd.HopLine), desc = "[L]ine" },
    {
      "<leader><space>n",
      function()
        without_vimade(function()
          require("hop").hint_patterns({}, vim.fn.getreg("/"))
        end)()
      end,
      desc = "[N]ext pattern (based on what was searched on /)",
    },
    {
      "<leader><space>t",
      without_vimade(vim.cmd.HopNodes),
      desc = "[T]reesiter nodes",
    },
    { "<leader><space>w", without_vimade(vim.cmd.HopWord), desc = "[W]ord" },
  },
  config = function()
    local hop = require("hop")

    hop.setup({
      multi_windows = true,
      quit_key = "<leader>",
    })

    local modes = { "n", "v" }

    vim.keymap.set(modes, "f", function()
      hop.hint_char1({
        direction = require("hop.hint").HintDirection.AFTER_CURSOR,
        current_line_only = true,
      })
    end, { desc = "Hop [f]or char (forward)" })

    vim.keymap.set(modes, "F", function()
      hop.hint_char1({
        direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
        current_line_only = true,
      })
    end, { desc = "Hop [f]or char (backward)" })

    vim.keymap.set(modes, "t", function()
      hop.hint_char1({
        direction = require("hop.hint").HintDirection.AFTER_CURSOR,
        current_line_only = true,
        hint_offset = -1,
      })
    end, { desc = "Hop '[t]il char (forward)" })

    vim.keymap.set(modes, "T", function()
      hop.hint_char1({
        direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
        current_line_only = true,
        hint_offset = -1,
      })
    end, { desc = "Hop '[t]il char (backward)" })
  end,
}
